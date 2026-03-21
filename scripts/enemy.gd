extends CharacterBody2D
class_name Enemy

@export var speed: float = 60.0
@export var health: int = 3
@export var recoil = 200
@export var recoil_timer_length = 0.1
@export var gem_count: int = 1

var gem_scene = preload("res://scenes/gem.tscn")

var direction = 1
var is_dead = false
var gravity = 900.0
var last_flip_time = 0.0

var recoil_timer = 0.0
var pre_recoil_velocity : Vector2 = Vector2.ZERO

var death_fling_v = -250.0 
var death_fling_h = 150.0  

@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast = $RayCast
@onready var killzone = $Killzone

func _physics_process(delta: float):
	if is_dead:
		velocity.y += gravity * delta
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if recoil_timer > 0:
		recoil_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 400 * delta)
	else:
		handle_behavior(delta)

	move_and_slide()

func handle_behavior(_delta):
	pass 

func _perform_flip():
	direction *= -1
	animated_sprite.flip_h = (direction == -1)

	if ray_cast:
		ray_cast.position.x = abs(ray_cast.position.x) * direction
		if ray_cast.target_position.x != 0:
			ray_cast.target_position.x = abs(ray_cast.target_position.x) * direction

	position.x += direction * 2.0

func take_damage():
	if is_dead: return
	health -= 1
	flash_white()

	pre_recoil_velocity = velocity

	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var knockback_dir = sign(global_position.x - player_node.global_position.x)
		if knockback_dir == 0: knockback_dir = 1
		recoil_timer = recoil_timer_length
		velocity += Vector2(knockback_dir * recoil, 0)

	if health <= 0:
		var fling_dir = 1
		if player_node:
			fling_dir = sign(global_position.x - player_node.global_position.x)
			if fling_dir == 0: fling_dir = 1
		die(fling_dir)

func flash_white():
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(10, 10, 10, 1), 0.05)
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.05)

func die(fling_dir: int):
	is_dead = true
	velocity = Vector2(fling_dir * 150.0, -250.0)

	collision_layer = 0 
	collision_mask = 1 

	if animated_sprite.sprite_frames.has_animation("dead"):
		animated_sprite.play("dead")
		animated_sprite.stop()

	spawn_gems()

	if killzone:
		killzone.set_deferred("monitoring", false)

func spawn_gems():
	if gem_scene:
		for i in range(gem_count):
			var gem = gem_scene.instantiate() 

			get_parent().add_child(gem) 
			gem.global_position = global_position

			if gem is CharacterBody2D:
				gem.is_popped = true # Enables physics in your gem.gd 
				gem.velocity = Vector2(randf_range(-100, 100), randf_range(-150, -250))
