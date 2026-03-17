extends CharacterBody2D

const PATROL_SPEED = 20.0  
const CHASE_SPEED = 60.0  
var current_speed = PATROL_SPEED
var direction = -1
var gravity = 800.0
var is_dead = false

var is_chasing = false
var is_skidding = false
var last_player_pos = Vector2.ZERO
var chase_timer = 0.0
const CHASE_TIMEOUT = 3.0 
const SKID_TIME = 0.4

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var player_detector = $PlayerDetector # The new RayCast
@onready var animated_sprite = $AnimatedSprite2D
@onready var killzone = $Killzone

@export var health: int = 3
@export var knockback_force: float = 100.0 

var gem_scene = preload("res://scenes/gem.tscn")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead:
		velocity.x = move_toward(velocity.x, 0, 400 * delta)
	else:
		handle_detection(delta)
		handle_movement(delta)

	move_and_slide()

func handle_movement(delta):
	var target_vel = 0.0
	if not is_skidding:
		target_vel = direction * current_speed

	var friction = 1200.0 
	
	if is_skidding:
		target_vel = 0.0
		friction = 150.0 
	else:
		target_vel = direction * current_speed
	
	velocity.x = move_toward(velocity.x, target_vel, friction * delta)

	if is_on_floor() and not is_chasing and not is_skidding:
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		elif ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false

func handle_detection(delta):
	player_detector.target_position.x = direction * 150.0
	var player = get_tree().get_first_node_in_group("player")
	
	if player_detector.is_colliding():
		var collider = player_detector.get_collider()
		if collider.is_in_group("player"):
			is_chasing = true
			chase_timer = CHASE_TIMEOUT 
	
	# 2. Chasing & Skidding Logic
	if is_chasing:
		current_speed = CHASE_SPEED
		chase_timer -= delta
		
		if player:
			var dir_to_player = sign(player.global_position.x - global_position.x)
			if dir_to_player != 0 and dir_to_player != direction and not is_skidding:
				start_skid(dir_to_player)
		
		if chase_timer <= 0:
			is_chasing = false
	else:
		current_speed = PATROL_SPEED

func take_damage():
	if is_dead: return
	health -= 1
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var knock_dir = sign(global_position.x - player.global_position.x)
		if knock_dir == 0: knock_dir = 1
		
		if health <= 0:
			die(knock_dir)
		else:
			velocity = Vector2(knock_dir * knockback_force, 0) 
			flash_white()

func start_skid(new_dir):
	is_skidding = true
	await get_tree().create_timer(SKID_TIME).timeout

	if not is_dead:
		direction = new_dir
		animated_sprite.flip_h = (direction == -1)
		is_skidding = false

func die(knock_dir):
	is_dead = true
	drop_gem()

	z_index = 0 
	collision_mask = 1 
	animated_sprite.flip_v = true
	animated_sprite.position.y = 0 
	animated_sprite.modulate = Color(0.6, 0.6, 0.6, 1) 
	
	if animated_sprite.sprite_frames.has_animation("dead"):
		animated_sprite.play("dead")
	else:
		animated_sprite.stop()
	
	if killzone:
		killzone.set_deferred("monitoring", false)
		killzone.set_deferred("monitorable", false)
		var kz_shape = killzone.get_node_or_null("CollisionShape2D")
		if kz_shape:
			kz_shape.set_deferred("disabled", true)
	
	velocity = Vector2(knock_dir * 250, -200)
	velocity = Vector2(knock_dir * 200, -250)

func drop_gem():
	var gem = gem_scene.instantiate()
	gem.global_position = global_position
	gem.is_popped = true 
	gem.velocity = Vector2(randf_range(-80, 80), -250)
	get_parent().add_child(gem)

func flash_white():
	animated_sprite.modulate = Color(3.0, 3.0, 3.0) 
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
