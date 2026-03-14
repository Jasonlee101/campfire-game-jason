extends Area2D
@onready var death_sound = $DeathSound
@onready var timer = $Timer

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
			
			if body.global_position.x < global_position.x:
				body.velocity.x = -400
			else:
				body.velocity.x = 400
			
			if body.dead:
				Engine.time_scale = 0.5
				death_sound.play()
				timer.start()
func _on_timer_timeout():
	await SceneTransition.fade_out()
	Engine.time_scale = 1
	stats.score = 0
	get_tree().reload_current_scene()
	SceneTransition.fade_in()
