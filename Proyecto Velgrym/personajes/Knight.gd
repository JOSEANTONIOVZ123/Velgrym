extends CharacterBody2D

@export var velocidad := 100
@export var gravedad := 800
@export var fuerza_salto := -350
@export var tiempo_entre_ataques := 0.5
@export var impulso_ataque := 500
@export var impulso_vertical := -400
@export var tiempo_invulnerabilidad := 1.0

@onready var animacion := $Animacion
@onready var ray_izq := $RayCastParedIzq
@onready var ray_der := $RayCastParedDer
@onready var vida := $Vida
@onready var hitbox := $Hitbox
@onready var hitbox_shape := $Hitbox/CollisionShape2D

var ultima_direccion := 1
var puede_atacar := true
var esta_atacando := false
var esta_en_pared := false
var direccion_pared := 0
var bloqueo_direccion := 0
var impulso_salto_pared := 5.0
var tiempo_impulso := 0.0
var lado_bloqueado := 0
var invulnerable := false
var empuje := Vector2.ZERO
var esta_muerto := false
var ha_atacado_en_el_aire := false  # ← NUEVA VARIABLE

func _ready():
	vida.muerto.connect(_on_morir)
	vida.vida_cambiada.connect(_on_vida_cambiada)
	add_to_group("jugador")

func _physics_process(delta):
	if esta_muerto:
		return

	var direccion := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if direccion != 0:
		ultima_direccion = direccion
	if direccion == bloqueo_direccion:
		direccion = 0
	if not esta_atacando and tiempo_impulso <= 0:
		velocity.x = direccion * velocidad

	# Aplicar retroceso
	if empuje.length() > 0.1:
		velocity += empuje
		empuje = empuje.move_toward(Vector2.ZERO, 800 * delta)

	# Detección de paredes
	esta_en_pared = false
	direccion_pared = 0
	if not is_on_floor():
		if ray_izq.enabled and ray_izq.is_colliding():
			esta_en_pared = true
			direccion_pared = -1
		elif ray_der.enabled and ray_der.is_colliding():
			esta_en_pared = true
			direccion_pared = 1

	# Reactivación de raycasts y bloqueo
	if direccion_pared != 0 and direccion_pared != lado_bloqueado:
		ray_izq.enabled = true
		ray_der.enabled = true
		lado_bloqueado = 0

	if is_on_floor():
		ray_izq.enabled = true
		ray_der.enabled = true
		lado_bloqueado = 0
		ha_atacado_en_el_aire = false  # ← RESETEO AL TOCAR SUELO

	if esta_en_pared:
		bloqueo_direccion = 0
	if esta_en_pared and velocity.y > 30:
		velocity.y = 30

	if not is_on_floor():
		velocity.y += gravedad * delta

	# Saltos
	var saltar_pared := false
	if esta_en_pared and not is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			saltar_pared = true
		elif direccion != 0 and direccion != direccion_pared:
			saltar_pared = true

	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = fuerza_salto
	elif saltar_pared:
		velocity.y = fuerza_salto
		impulso_salto_pared = -direccion_pared * velocidad * 22
		tiempo_impulso = 0.2
		iniciar_bloqueo_direccion(direccion_pared)
		lado_bloqueado = direccion_pared
		if direccion_pared == -1:
			ray_izq.enabled = false
		elif direccion_pared == 1:
			ray_der.enabled = false

	if tiempo_impulso > 0:
		velocity.x = move_toward(velocity.x, impulso_salto_pared, 800 * delta)
		tiempo_impulso -= delta
	else:
		impulso_salto_pared = 0.0

	# Ataque
	if Input.is_action_just_pressed("ataque") and puede_atacar:
		atacar()

	# Animaciones
	if not esta_atacando:
		if not is_on_floor():
			var anim = "saltar" if velocity.y < 0 else "caer"
			animacion.play(anim)
		elif direccion != 0:
			animacion.play("caminar")
		else:
			animacion.play("tranquilo")
		animacion.flip_h = ultima_direccion < 0

	move_and_slide()

func iniciar_bloqueo_direccion(dir: int) -> void:
	bloqueo_direccion = dir
	await get_tree().create_timer(0.5).timeout
	bloqueo_direccion = 0

func atacar():
	# Evita múltiples ataques en el aire
	if not is_on_floor():
		if ha_atacado_en_el_aire:
			return
		ha_atacado_en_el_aire = true

	puede_atacar = false
	esta_atacando = true
	invulnerable = true

	hitbox_shape.disabled = true
	animacion.play("atacar")
	animacion.flip_h = ultima_direccion < 0

	hitbox.position.x = abs(hitbox.position.x) * ultima_direccion
	velocity.x = ultima_direccion * impulso_ataque
	velocity.y = impulso_vertical

	for cuerpo in hitbox.get_overlapping_bodies():
		if cuerpo != self and cuerpo.has_node("Vida"):
			cuerpo.get_node("Vida").recibir_daño(1, self)

	await get_tree().create_timer(tiempo_entre_ataques).timeout

	invulnerable = false
	hitbox_shape.disabled = false
	puede_atacar = true
	esta_atacando = false

func recibir_daño(cantidad: int, fuente = null):
	if invulnerable or vida.esta_muerto:
		return

	if fuente:
		var dir: Vector2 = (global_position - fuente.global_position).normalized()
		empuje = dir * 200
		empuje.y = -60

	vida.recibir_daño(cantidad, fuente)
	activar_invulnerabilidad()

func activar_invulnerabilidad():
	invulnerable = true
	for i in range(4):
		animacion.modulate.a = 0.2
		await get_tree().create_timer(0.1).timeout
		animacion.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout
	invulnerable = false

func _on_vida_cambiada(v):
	print("💔 Vida actual: ", v)

func _on_morir():
	print("☠️ El caballero ha muerto.")
	esta_muerto = true
	animacion.play("morir")
	await animacion.animation_finished

	# ✅ MOSTRAR HUD
	GameOverHud.mostrar_con_mensaje("¡El Caballero ha muerto!")

	# ❌ NO hagas queue_free aún. Espera a que el jugador pulse un botón
	# El personaje se queda quieto, sin controles
