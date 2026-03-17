extends CharacterBody2D

const SPEED = 60.0
var direction = -1
var gravity = 800.0
var can_be_hurt = true

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

@onready var health: int = 3
@onready var knockback_force: float = 200.0 
@onready var interaction_range: float = 80.0

var gem_scene = preload("res://scenes/gem.tscn")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	var target_velocity_x = direction * SPEED
	velocity.x = move_toward(velocity.x, target_velocity_x, 1200 * delta)

	if is_on_floor():
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		if ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false

	move_and_slide()

func take_damage():
	if not can_be_hurt: return

	can_be_hurt = false
	health -= 1

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var knock_dir = sign(global_position.x - player.global_position.x)
		velocity.x = knock_dir * knockback_force
		
	flash_white()
	await get_tree().create_timer(0.2).timeout
	can_be_hurt = true

	if health <= 0: 
		drop_gem()
		queue_free()

func drop_gem():
	var gem = gem_scene.instantiate()
	gem.global_position = global_position
	gem.is_popped = true 
	gem.velocity = Vector2(randf_range(-80, 80), -100)
	get_parent().add_child(gem)

func flash_white():
	animated_sprite.modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
