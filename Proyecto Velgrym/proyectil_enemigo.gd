extends Area2D

@export var velocidad := 200
var direccion := Vector2.ZERO

@onready var animacion := $Bala  # Asegúrate de que el nodo se llama exactamente "Bala"

func _ready():
	animacion.play("Bala")
	connect("body_entered", _on_body_entered)
	set_process(true)  # Activa _process() manualmente en Godot 4

func set_direccion(dir: Vector2):
	direccion = dir.normalized()
	# print("Dirección proyectil:", direccion)  # Puedes descomentar si quieres depurar

func _process(delta):
	position += direccion * velocidad * delta
	# print("Posición actual:", position)  # Puedes descomentar para ver si se mueve

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		body.recibir_daño(1)  # Cambia según tu sistema de daño
	queue_free()  # Desaparece al colisionar
