extends Node

signal vida_cambiada(vida_actual)
signal muerto

@export var vida_max := 1
var vida_actual := 0
var esta_muerto := false

func _ready():
	vida_actual = vida_max

func recibir_daño(cantidad: int, fuente = null):
	if esta_muerto:
		print("Ya está muerto, no recibe más daño")
		return

	vida_actual -= cantidad
	print("Vida actual:", vida_actual)
	emit_signal("vida_cambiada", vida_actual)

	# Retroceso o animación de golpe
	if owner and owner.has_method("reaccionar_a_golpe") and fuente:
		owner.reaccionar_a_golpe(fuente.global_position)

	if vida_actual <= 0:
		esta_muerto = true
		emit_signal("muerto")
