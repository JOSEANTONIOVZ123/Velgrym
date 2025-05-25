extends Node2D

var personaje_a_activar: String

func _ready():
	var personaje = Global.instanciar_personaje()
	if personaje:
		personaje.position = $Spawn.global_position
		add_child(personaje)


func instanciar_personaje(ruta: String):
	var personaje = load(ruta).instantiate()
	personaje.position = $Spawn.global_position
	add_child(personaje)




func _on_area_cambio_escena_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("✅ TOCADO EL TRIGGER")
		get_tree().change_scene_to_file("res://mapas/pradera.tscn")
		
