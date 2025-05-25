extends CharacterBody2D

@export var velocidad := 60
@export var daño := 1
@export var cooldown_ataque := 1.0

@onready var animacion := $AnimatedSprite2D
@onready var detector := $DetectorJugador
@onready var vida := $Vida
@onready var hitbox := $Hitbox

var punto_reposo: Vector2
var objetivo: CharacterBody2D = null
var puede_atacar := true
var empuje := Vector2.ZERO
var esta_dormido := true
var ha_llegado_al_techo := false

func _ready():
	vida.muerto.connect(_on_morir)
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

	punto_reposo = global_position

func _physics_process(delta):
	if vida.esta_muerto:
		return

	if objetivo and not esta_dormido:
		var dir = (objetivo.global_position - global_position).normalized()
		velocity = dir * velocidad
		animacion.flip_h = dir.x < 0
		ha_llegado_al_techo = false

	elif esta_dormido and not ha_llegado_al_techo:
		var dir = (punto_reposo - global_position).normalized()
		velocity = dir * velocidad

		if global_position.distance_to(punto_reposo) < 5:
			velocity = Vector2.ZERO
			animacion.play("ceilin_in")
			animacion.flip_v = true
			ha_llegado_al_techo = true
	else:
		velocity = Vector2.ZERO

	if empuje.length() > 0.1:
		velocity += empuje
		empuje = empuje.move_toward(Vector2.ZERO, 500 * delta)

	move_and_slide()

	if not vida.esta_muerto and not ha_llegado_al_techo:
		if empuje.length() > 10:
			animacion.play("daño")
		elif velocity.length() > 5:
			animacion.play("volar")
		else:
			animacion.play("idle")

	if puede_atacar and not esta_dormido:
		for cuerpo in hitbox.get_overlapping_bodies():
			if cuerpo != self and cuerpo.has_method("recibir_daño"):
				cuerpo.recibir_daño(daño, self)
				puede_atacar = false
				await get_tree().create_timer(cooldown_ataque).timeout
				puede_atacar = true
				break

func reaccionar_a_golpe(origen: Vector2):
	var dir = (global_position - origen).normalized()
	empuje = dir * 300
	empuje.y = -50

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		objetivo = body
		esta_dormido = false
		animacion.flip_v = false

func _on_body_exited(body):
	if body == objetivo:
		objetivo = null
		esta_dormido = true
		ha_llegado_al_techo = false

func _on_morir():
	animacion.flip_v = false
	animacion.play("daño")
	await animacion.animation_finished
	queue_free()
