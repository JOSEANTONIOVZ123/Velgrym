extends Node2D

@export var proyectil_escena: PackedScene

@onready var detector := $DetectorJugador
@onready var punto_disparo := $PuntoDisparo
@onready var sprite := $AnimatedSprite2D
@onready var disparo_timer := $DisparoTimer
@onready var hitbox := $Hitbox
@onready var vida := $Vida  # Nodo con vida.gd adjunto

var objetivo: Node2D = null
var puede_disparar := true
var en_daño := false

func _ready():
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animacion_finalizada)
	disparo_timer.wait_time = 1.0
	disparo_timer.timeout.connect(_on_DisparoTimer_timeout)
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	vida.vida_cambiada.connect(_on_vida_cambiada)
	vida.muerto.connect(_on_morir)

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		objetivo = body
		if puede_disparar and not en_daño:
			sprite.play("ataque")
			disparo_timer.start()

func _on_body_exited(body):
	if body == objetivo:
		objetivo = null
		sprite.play("idle")
		disparo_timer.stop()
		puede_disparar = true

func _on_DisparoTimer_timeout():
	if objetivo and puede_disparar and not en_daño:
		puede_disparar = false
		sprite.play("ataque")

func _on_animacion_finalizada():
	if sprite.animation == "ataque":
		_disparar()
		puede_disparar = true
		if objetivo and not en_daño:
			disparo_timer.start()
	elif sprite.animation == "daño":
		_on_animacion_daño_finalizada()
	elif sprite.animation == "morir":
		pass

func _disparar():
	var proyectil = proyectil_escena.instantiate()
	get_tree().current_scene.add_child(proyectil)
	var direccion = (objetivo.global_position - punto_disparo.global_position).normalized()
	proyectil.global_position = punto_disparo.global_position
	proyectil.set_direccion(direccion)
	
	# Invertimos la condición para corregir la orientación del sprite
	sprite.flip_h = direccion.x > 0
	
	sprite.play("idle")

func _on_hitbox_body_entered(body):
	if body.is_in_group("proyectil_enemigo"):
		vida.recibir_daño(1, body)
		body.queue_free()

func _on_vida_cambiada(nueva_vida):
	if en_daño:
		return
	en_daño = true
	sprite.play("daño")
	sprite.animation_finished.connect(_on_animacion_daño_finalizada)

func _on_animacion_daño_finalizada():
	if sprite.animation == "daño":
		en_daño = false
		sprite.animation_finished.disconnect(_on_animacion_daño_finalizada)
		if objetivo:
			sprite.play("ataque")
		else:
			sprite.play("idle")

func _on_morir():
	sprite.play("morir")
	disparo_timer.stop()
	objetivo = null
	set_physics_process(false)
	await sprite.animation_finished
	queue_free()
