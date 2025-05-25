extends CanvasLayer

@onready var mensaje = $FinalMessage
@onready var countdown = $CountdownLabel

func _ready():
	mensaje.visible = true
	countdown.visible = true
	empezar_cuenta_regresiva(5)

func empezar_cuenta_regresiva(segundos):
	if segundos > 0:
		countdown.text = "Saliendo en %d..." % segundos
		await get_tree().create_timer(1.0).timeout
		empezar_cuenta_regresiva(segundos - 1)
	else:
		countdown.text = "Cerrando juego..."
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
