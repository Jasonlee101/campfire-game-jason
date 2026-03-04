extends Area2D
@onready var death_sound = $DeathSound
@onready var timer = $Timer

func _on_body_entered(body):
	var death = body.dead
	var anim = body.get_node("AnimatedSprite2D")
	
	Engine.time_scale = 0.5
	body.dead = true
	body.velocity.y = -300.0
	
	if body.animated_sprite.flip_h:
		body.direction = 1 
	else:
		body.direction = -1 
	body.velocity.x = -200
	
	anim.play("death")  
	death_sound.play()
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	Stats.score = 0
	get_tree().reload_current_scene()
