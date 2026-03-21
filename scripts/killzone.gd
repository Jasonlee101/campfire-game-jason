extends Area2D
@export var is_instakill: bool = false
@onready var death_sound = $DeathSound
@onready var timer = $Timer

@export var damage_amount: int = 1

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)

	if is_instakill: 
		if body.has_method("die"):
			body.die()

	if body.dead:
		if body.global_position.x < global_position.x: 
			body.direction = -1
		else:
			body.direction = 1
		body.velocity.y = -300.0  
		body.velocity.x = -200   

		Engine.time_scale = 0.5
		if death_sound:
			death_sound.play()
		if timer:
			timer.start()

func _on_timer_timeout():
	SceneTransition.reload_scene()
