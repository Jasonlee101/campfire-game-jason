extends Area2D
@onready var death_sound = $DeathSound
@onready var timer = $Timer

func _on_body_entered(body):
	if body.is_in_group("player"):
		if "is_invulnerable" in body and body.is_invulnerable:
			print("Killzone blocked by invincibility!")
			return
		
		var death = body.dead 
		var anim = body.get_node("AnimatedSprite2D")
		
		body.dead = true

		if body.global_position.x < global_position.x:
			body.direction = -1 
		else:
			body.direction = 1 
			
		body.velocity.y = -300.0
		body.velocity.x = -200
		
		Engine.time_scale = 0.5
		body.dead = true
		anim.play("death")  
		death_sound.play()
		timer.start()

func _on_timer_timeout():
	await SceneTransition.fade_out()
	Engine.time_scale = 1
	stats.score = 0
	get_tree().reload_current_scene()
	SceneTransition.fade_in()
