extends CharacterBody2D

@export var velocidad := 20
@export var daño := 1
@export var cooldown_ataque := 1.0

@onready var animacion := $AnimatedSprite2D
@onready var detector := $DetectorJugador
@onready var vida := $Vida
@onready var hitbox := $Hitbox

var objetivo: CharacterBody2D = null
var direccion := Vector2.ZERO
var puede_atacar := true
var empuje := Vector2.ZERO

func _ready():
	vida.muerto.connect(_on_morir)
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if objetivo and not vida.esta_muerto:
		var objetivo_dir = (objetivo.global_position - global_position).normalized()
		direccion = Vector2(sign(objetivo_dir.x), 0)
		velocity.x = direccion.x * velocidad
		animacion.flip_h = direccion.x < 0
	else:
		velocity.x = 0

	if empuje.length() > 0.1:
		velocity += empuje
		empuje = empuje.move_toward(Vector2.ZERO, 500 * delta)

	if not is_on_floor():
		velocity.y += 600 * delta
	else:
		velocity.y = 0

	move_and_slide()

	if not vida.esta_muerto:
		if empuje.length() > 10:
			animacion.play("golpeado")
		elif abs(velocity.x) > 0:
			animacion.play("caminar")
		else:
			animacion.play("idle")

	if puede_atacar:
		var cuerpos = hitbox.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo != self and cuerpo.has_method("recibir_daño"):
				cuerpo.recibir_daño(daño, self)
				puede_atacar = false
				await get_tree().create_timer(cooldown_ataque).timeout
				puede_atacar = true
				break

func reaccionar_a_golpe(origen: Vector2):
	var dir = (global_position - origen).normalized()
	empuje = dir * 300

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		objetivo = body

func _on_body_exited(body):
	if body == objetivo:
		objetivo = null

func _on_morir():
	animacion.play("morir")
	await animacion.animation_finished
	queue_free()
