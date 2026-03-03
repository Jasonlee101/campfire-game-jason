extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	Engine.time_scale = 0.5
	var death = body.dead
	body.dead = true
	var anim = body.get_node("AnimatedSprite2D")
	body.velocity.y = -300.0
	anim.play("death")  
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	Stats.score = 0
	get_tree().reload_current_scene()
