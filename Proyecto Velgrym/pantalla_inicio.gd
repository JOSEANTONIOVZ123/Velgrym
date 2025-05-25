extends Control

@onready var boton_caballero := $VBoxContainer/BotonCaballero
@onready var boton_gato := $VBoxContainer/BotonGato

func _ready():
	boton_caballero.pressed.connect(_on_boton_caballero_pressed)
	boton_gato.pressed.connect(_on_boton_gato_pressed)

func _on_boton_caballero_pressed():
	iniciar_juego_con("caballero")

func _on_boton_gato_pressed():
	iniciar_juego_con("gato")

func iniciar_juego_con(tipo: String):
	Global.personaje_tipo = tipo
	Global.posicion_inicio = Vector2(100, 100) # o donde deba aparecer en cueva
	Global.siguiente_escena = "res://mapas/mapa_cueva_inicio.tscn"
	Global.cargar_siguiente_escena()
