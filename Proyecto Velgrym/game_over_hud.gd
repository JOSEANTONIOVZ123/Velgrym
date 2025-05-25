extends CanvasLayer

@onready var panel := $Control/Panel
@onready var label := $Control/Panel/VBoxContainer/Label
@onready var boton_reintentar := $Control/Panel/VBoxContainer/HBoxContainer/Button
@onready var boton_salir := $Control/Panel/VBoxContainer/HBoxContainer/Button2

func _ready():
	hide()
	boton_reintentar.pressed.connect(_on_reintentar_pressed)
	boton_salir.pressed.connect(_on_salir_pressed)

func mostrar_con_mensaje(texto: String):
	label.text = texto
	await get_tree().process_frame
	var pantalla := get_viewport().get_visible_rect().size
	panel.position = pantalla / 2 - panel.size / 2
	show()
	panel.show()

func posicionar_en_camara():
	var camara := get_viewport().get_camera_2d()
	if camara:
		var camara_pos := camara.get_screen_center_position()
		panel.position = camara_pos - panel.size / 2

func mover_camara_a_hud():
	var camara := get_viewport().get_camera_2d()
	if camara:
		var panel_centro: Vector2 = panel.global_position + panel.size / 2
		camara.global_position = panel_centro

func _on_reintentar_pressed():
	hide()
	get_tree().reload_current_scene()

func _on_salir_pressed():
	get_tree().quit()
