extends Enemy

func _init():
	speed = 60.0
	health = 5
	gem_count = 3

func handle_behavior(_delta):
	if is_on_wall() or ray_cast.is_colliding():
		_perform_flip()

	velocity.x = direction * speed
	animated_sprite.play("default")
