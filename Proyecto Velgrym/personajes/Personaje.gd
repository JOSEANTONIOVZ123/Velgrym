extends CharacterBody2D

# --- CONSTANTES ---
const VELOCIDAD = 150
const GRAVEDAD = 900
const SALTO = -500
const TIEMPO_INVULNERABLE = 1.0
const TIEMPO_CAIDA_PLATAFORMA = 0.2
const TIEMPO_MAXIMO_BAJA = 5.0 # 5 segundos de espera para repetir

# --- VARIABLES ---
var vida = 1
var direccion = 0
var retroceso = Vector2.ZERO
var invulnerable = false
var tiempo_invulnerable = 0.0
var is_dropping = false
var drop_timer = 0.0

# --- PARA EL CONTADOR DE TIEMPO ---
var tiempo_baja = TIEMPO_MAXIMO_BAJA # Tiempo restante para poder volver a bajar
var puede_bajar = true # Flag para controlar si se puede hacer la acción de bajar

var agarrado_pared = false
var direccion_pared = 0  # -1 izquierda, 1 derecha

# --- FUNCIONES PRINCIPALES ---

func _physics_process(delta):
	direccion = 0

	if is_dropping:
		drop_timer -= delta
		if drop_timer <= 0:
			set_collision_mask_value(1, true)
			is_dropping = false

	# --- LOGICA DE TIEMPO PARA LA ACCIÓN DE BAJAR ---
	if not puede_bajar:
		tiempo_baja -= delta
		if tiempo_baja <= 0:
			puede_bajar = true
			tiempo_baja = TIEMPO_MAXIMO_BAJA # Reset del tiempo de espera para permitir de nuevo

	intentar_caer()

	if retroceso == Vector2.ZERO:
		if Input.is_action_pressed("ui_left"):
			direccion = -1
		elif Input.is_action_pressed("ui_right"):
			direccion = 1
		velocity.x = direccion * VELOCIDAD
	else:
		velocity.x = retroceso.x
		retroceso = retroceso.move_toward(Vector2.ZERO, 500 * delta)

	detectar_pared(delta)
	aplicar_gravedad(delta)
	controlar_saltos()
	controlar_escaleras()
	ajustar_snap_suelo()

	if Input.is_action_just_pressed("ui_accept"):
		atacar()

	controlar_invulnerabilidad(delta)

	move_and_slide()

# --- FUNCIONES SECUNDARIAS ---

func intentar_caer():
	if Input.is_action_just_pressed("ui_down") and puede_bajar:  # Solo si se puede bajar
		if is_on_floor():
			print("✅ En suelo, bajando...")
			set_collision_mask_value(1, false)
			is_dropping = true
			drop_timer = TIEMPO_CAIDA_PLATAFORMA
			velocity.y += 50
			puede_bajar = false # Inhabilitamos el uso hasta que pase el tiempo
		else:
			print("🚫 No hay plataforma debajo. No bajar.")

func detectar_pared(delta):
	if not is_on_floor():
		var colision = move_and_collide(Vector2(velocity.x * delta, 0))
		if colision and colision.get_collider():
			agarrado_pared = true
			direccion_pared = sign(colision.get_normal().x)
		else:
			agarrado_pared = false
	else:
		agarrado_pared = false

func aplicar_gravedad(delta):
	if agarrado_pared:
		velocity.y = min(velocity.y, 100)
	else:
		velocity.y += GRAVEDAD * delta

func controlar_saltos():
	if is_on_floor() and Input.is_action_just_pressed("ui_up") and retroceso == Vector2.ZERO:
		velocity.y = SALTO
	elif agarrado_pared and Input.is_action_just_pressed("ui_up"):
		velocity.y = SALTO
		velocity.x = -direccion_pared * (VELOCIDAD * 1.2)
		agarrado_pared = false

func controlar_escaleras():
	if is_on_floor() and not agarrado_pared:
		if $RaycastEscalera.is_colliding():
			velocity.y = SALTO / 2

func ajustar_snap_suelo():
	if is_on_floor():
		set_floor_snap_length(10.0)
	else:
		set_floor_snap_length(0.0)

func controlar_invulnerabilidad(delta):
	if invulnerable:
		tiempo_invulnerable -= delta
		if tiempo_invulnerable <= 0:
			invulnerable = false
			$Sprite2D.modulate = Color(1, 1, 1)

func recibir_daño(cantidad, atacante_pos = null):
	if invulnerable:
		return

	vida -= cantidad
	parpadear_rojo()

	invulnerable = true
	tiempo_invulnerable = TIEMPO_INVULNERABLE

	if atacante_pos != null:
		var direccion_retroceso = (global_position - atacante_pos).normalized()
		retroceso = direccion_retroceso * 400
		velocity.y = -200

	print("¡Me han golpeado! Vida restante: ", vida)

	if vida <= 0:
		morir()

func morir():
	print("¡Has muerto!")

	var panel_muerte = get_node_or_null("/root/MapaPruebas/CanvasLayer/Control/Panel")
	if panel_muerte:
		panel_muerte.visible = true
		print("HUD de muerte mostrado correctamente")
	else:
		print("ERROR: No se encontró el Panel de muerte")

	set_physics_process(false)
	hide()

func atacar():
	for slime in get_tree().get_nodes_in_group("enemigos"):
		if slime is CharacterBody2D and slime.has_method("recibir_daño"):
			var distancia = global_position.distance_to(slime.global_position)
			if distancia < 80:
				slime.recibir_daño(1, global_position)

func parpadear_rojo():
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.modulate = Color(1, 1, 1)

func _on_muertevacio_body_entered(body):
	if body == self:
		morir()
