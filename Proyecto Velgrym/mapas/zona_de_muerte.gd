extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("💥 Entró:", body.name)

	if body.is_in_group("jugador") and body.has_method("recibir_daño"):
		body.recibir_daño(9999, self)  # daño letal
