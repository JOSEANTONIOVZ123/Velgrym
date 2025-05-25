extends Node

func _ready():
	get_tree().change_scene_to_file(Global.siguiente_escena)
	await get_tree().process_frame

	var personaje
	if Global.personaje_tipo == "knight":
		personaje = preload("res://Knight.tscn").instantiate()

	personaje.position = Global.posicion_inicio
	get_tree().current_scene.add_child(personaje)

	var color_rect = get_tree().current_scene.get_node_or_null("CanvasLayer/ColorRect")
	var anim = get_tree().current_scene.get_node_or_null("AnimationPlayer")
	if color_rect:
		color_rect.modulate.a = 1.0
		if anim and anim.has_animation("fade_in"):
			anim.play("fade_in")
