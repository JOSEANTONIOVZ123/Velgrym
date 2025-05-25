extends Node2D

func _ready():
	var personaje = Global.instanciar_personaje()
	if personaje:
		personaje.position = $Spawn.global_position
		add_child(personaje)

		var camara = Camera2D.new()
		camara.make_current()  
		personaje.add_child(camara)
