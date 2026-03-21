extends Enemy

@export_group("Fly Patrol")
@export var patrol_speed = 50.0

@export_group("Fly Swoop")
@export var swoop_speed = 120.0
@export var swoop_duration = 0.8
@export var detection_range = 120.0
@export var swoop_cooldown = 2.0 

var is_swooping = false
var swoop_timer = 0.0
var cooldown_timer = 0.0
var swoop_dir = Vector2.ZERO

@onready var player_detector = $PlayerDetector

func _init():
	gravity = 0 
	speed = patrol_speed
	health = 3
	gem_count = 3

func _ready():
	velocity = Vector2(1, 0.5).normalized() * patrol_speed
	if player_detector:
		player_detector.add_exception(self)

func handle_behavior(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta

	var player = get_tree().get_first_node_in_group("player")
	var can_see_player = false

	if not is_swooping and cooldown_timer <= 0:
		if player and player_detector and not player.dead:
			var dist = global_position.distance_to(player.global_position)
			if dist < detection_range:
				player_detector.target_position = to_local(player.global_position)
				player_detector.force_raycast_update()

				if player_detector.is_colliding():
					var target = player_detector.get_collider()
					if target and target.is_in_group("player"):
						can_see_player = true

	if can_see_player and not is_swooping:
		is_swooping = true
		swoop_timer = swoop_duration
		swoop_dir = (player.global_position - global_position).normalized()
		if animated_sprite.sprite_frames.has_animation("swoop"):
			animated_sprite.play("swoop")
		else:
			animated_sprite.play("chase")

	if is_swooping:
		swoop_timer -= delta
		velocity = swoop_dir * swoop_speed
		
		if swoop_timer <= 0:
			is_swooping = false
			cooldown_timer = swoop_cooldown
			velocity = velocity.normalized() * patrol_speed
	else:
		if animated_sprite.animation != "default":
			animated_sprite.play("default")
		
		if velocity.length() > patrol_speed:
			velocity = velocity.move_toward(velocity.normalized() * patrol_speed, 200 * delta)

	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal)
		if is_swooping:
			swoop_dir = velocity.normalized()
		position += normal * 2.0

	if abs(velocity.x) > 0.1:
		direction = sign(velocity.x)
		animated_sprite.flip_h = (direction == -1)

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
