extends Node

var siguiente_escena: String = ""
var posicion_inicio: Vector2 = Vector2.ZERO
var personaje_tipo: String = ""  # "caballero", "gato", etc.

func cargar_siguiente_escena():
	if siguiente_escena != "":
		get_tree().change_scene_to_file(siguiente_escena)

func instanciar_personaje():
	var ruta = ""
	match personaje_tipo:
		"caballero":
			ruta = "res://Knight.tscn"
		"gato":
			ruta = "res://gato.tscn"

	if ruta != "":
		var personaje = load(ruta).instantiate()
		personaje.position = posicion_inicio
		return personaje
	return null

func hacer_algo_con_nodo():
	if get_tree().has_current_scene():
		var nodo = get_tree().current_scene.get_node_or_null("MiNodo")
		if nodo:
			nodo.do_something()
