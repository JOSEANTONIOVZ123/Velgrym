extends CharacterBody2D

@export var velocidad := 30
@export var vida_max := 5

@onready var animacion := $AnimatedSprite2D
@onready var detector_pies := $DetectorPies
@onready var detector_golpe := $DetectorGolpe

var direccion := -1
var vida_actual := 0
var esta_muerto := false
var puede_dañar := true

func _ready():
	vida_actual = vida_max
	detector_pies.body_entered.connect(_on_pisado)
	detector_golpe.body_entered.connect(_on_golpear_jugador)

func _physics_process(delta):
	if esta_muerto:
		velocity.x = 0
	else:
		velocity.x = direccion * velocidad

	velocity.y += 600 * delta  # gravedad
	move_and_slide()

	if is_on_wall():
		direccion *= -1
		animacion.flip_h = direccion < 0

	if not esta_muerto:
		animacion.play("caminar")

func recibir_daño(cantidad: int, fuente = null):
	if esta_muerto:
		return

	if fuente == "pisoton" :
		vida_actual = 0
	else:
		vida_actual -= cantidad

	if vida_actual <= 0:
		_morir()

func _on_pisado(body):
	if body.name == "Knight":
		recibir_daño(vida_max, "pisoton")

func _on_golpear_jugador(body):
	if esta_muerto or not puede_dañar:
		return

	if body.name == "Knight" and body.has_method("recibir_daño"):
		puede_dañar = false
		body.recibir_daño(1, self)
		await get_tree().create_timer(1.0).timeout
		puede_dañar = true

func _morir():
	if esta_muerto:
		return
	esta_muerto = true

	animacion.play("morir")

	await animacion.animation_finished
	queue_free()
