extends CharacterBody2D

@export var velocidad_normal := 150
@export var velocidad_sprint := 240
@export var salto := -350
@export var gravedad := 800
@export var velocidad_escalada := 100
@export var tiempo_escalada_max := 1.5

@onready var animacion := $AnimatedSprite2D
@onready var ray_izq := $RayCastParedIzq
@onready var ray_der := $RayCastParedDer
@onready var vida := $Vida

var escondiendose := false
var escalando := false
var colgado := false
var tiempo_escalando := 0.0
var invulnerable := false
var esta_muerto := false

func _ready():
	add_to_group("jugador")
	vida.vida_max = 2
	vida.vida_actual = 2
	vida.muerto.connect(_on_morir)

func _physics_process(delta):
	if escondiendose or esta_muerto:
		move_and_slide()
		return

	var direccion := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var velocidad := velocidad_normal

	if Input.is_action_pressed("ui_select"):
		velocidad = velocidad_sprint

	velocity.x = direccion * velocidad

	var tocando_pared: bool = ray_izq.is_colliding() or ray_der.is_colliding()

	if not is_on_floor() and tocando_pared and tiempo_escalando < tiempo_escalada_max:
		if is_on_ceiling():
			colgado = true
			escalando = false
			tiempo_escalando += delta
			velocity.y = 0
		else:
			escalando = true
			colgado = false
			velocity.y = -velocidad_escalada
			tiempo_escalando += delta
	else:
		escalando = false
		colgado = false
		if not is_on_floor():
			velocity.y += gravedad * delta
		else:
			tiempo_escalando = 0.0

	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = salto

	if Input.is_action_just_pressed("ui_down"):
		esconderse()
		move_and_slide()
		return

	if escalando:
		animacion.play("correr")
		if ray_der.is_colliding():
			animacion.rotation_degrees = -90
			animacion.flip_h = false
		else:
			animacion.rotation_degrees = -270
			animacion.flip_h = true
	elif colgado:
		animacion.play("correr")
		animacion.rotation_degrees = 180
		animacion.flip_h = direccion < 0
	elif direccion != 0:
		animacion.play("sprint" if velocidad == velocidad_sprint else "correr")
		animacion.flip_h = direccion < 0
		animacion.rotation_degrees = 0
	else:
		animacion.play("idle")
		animacion.rotation_degrees = 0

	move_and_slide()

func esconderse():
	escondiendose = true
	velocity = Vector2.ZERO
	animacion.rotation_degrees = 0
	animacion.play("esconderse")
	await animacion.animation_finished
	escondiendose = false

func recibir_daño(cantidad: int, fuente = null):
	if vida.esta_muerto or esta_muerto:
		return

	if invulnerable and cantidad < vida.vida_actual:
		return

	if fuente:
		var dir: Vector2 = (global_position - fuente.global_position).normalized()
		velocity += dir * 120
		velocity.y = -60

	vida.recibir_daño(cantidad, fuente)

	if vida.vida_actual > 0:
		activar_invulnerabilidad()

func activar_invulnerabilidad():
	invulnerable = true
	for i in range(4):
		animacion.modulate.a = 0.2
		await get_tree().create_timer(0.1).timeout
		animacion.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout
	invulnerable = false

func _on_morir():
	esta_muerto = true
	animacion.rotation_degrees = 0
	animacion.play("morir")
	await animacion.animation_finished

	if Engine.has_singleton("GameOverHud"):
		var hud = Engine.get_singleton("GameOverHud")
		if hud.has_method("mostrar_con_mensaje"):
			hud.mostrar_con_mensaje("¡El Gato ha muerto!")
	else:
		GameOverHud.mostrar_con_mensaje("¡El Gato ha muerto!")

	await get_tree().create_timer(0.1).timeout
	queue_free()
