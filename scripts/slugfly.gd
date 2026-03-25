extends Enemy
@export var is_hovering: bool = false

func _init():
	gravity = 0 
	speed = 60.0 
	health = 5 
	recoil = 150
	gem_count = 2

func _ready():
	var starting_dir = Vector2(1.5, 1).normalized()
	velocity = starting_dir * speed

func handle_behavior(delta):
	if is_hovering:
		velocity.x = 0
		velocity.y = 0
		return

	if ray_cast and velocity.length() > 0:
		ray_cast.target_position = velocity.normalized() * 20.0

	var collision = move_and_collide(velocity * delta)

	if collision:
		velocity = velocity.bounce(collision.get_normal())
		velocity = velocity.normalized() * speed

		if velocity.x != 0:
			direction = sign(velocity.x)
			animated_sprite.flip_h = (direction == -1)

	animated_sprite.play("default")

func _physics_process(delta: float):
	if is_dead:
		velocity.y += 900.0 * delta
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
		move_and_slide()
		return
	
	if recoil_timer > 0:
		recoil_timer -= delta
		move_and_slide()
		if recoil_timer <= 0:
			velocity = pre_recoil_velocity
		return

	handle_behavior(delta)
