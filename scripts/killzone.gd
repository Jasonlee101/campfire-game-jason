extends Area2D
@onready var death_sound = $DeathSound
@onready var timer = $Timer

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
			
			if body.dead:
				# Set direction for the death fall
				if body.global_position.x < global_position.x:
					body.direction = -1
				else:
					body.direction = 1

				body.velocity.y = -300.0  # The "jump" you're seeing
				body.velocity.x = -200    # The horizontal push
				
				Engine.time_scale = 0.5
				death_sound.play()
				timer.start()

func _on_timer_timeout():
	await SceneTransition.fade_out()
	Engine.time_scale = 1
	stats.score = 0
	get_tree().reload_current_scene()
	SceneTransition.fade_in()
