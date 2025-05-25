extends Area2D

var mensaje_escena = preload("res://mapas/FinalMessage.tscn")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Entró:", body.name)
	if body.is_in_group("jugador"):
		var mensaje = mensaje_escena.instantiate()
		get_tree().get_root().add_child(mensaje)
