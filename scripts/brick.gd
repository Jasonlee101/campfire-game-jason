extends StaticBody2D

enum BrickType { NORMAL, GEM_CLUSTER }

@export var type: BrickType = BrickType.NORMAL
@export var gem_scene: PackedScene = preload("res://scenes/gem.tscn")
@export var interaction_range: float = 40.0
@export var flip_vertical: bool = false
@export var disable_collision: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var tap_sound = $TapSound
@onready var break_sound = $BreakSound
@onready var collision_shape = $CollisionShape2D
@onready var player = get_tree().get_first_node_in_group('player')

var health = 3

func _ready():
	animated_sprite.flip_v = flip_vertical
	collision_shape.set_deferred("disabled", disable_collision)
	
	if type == BrickType.GEM_CLUSTER:
		animated_sprite.play("gem_3")

	else:
		animated_sprite.play("3")

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.is_action_pressed("mine"):
		if health >= 1:
			if player == null:
				player = get_tree().get_first_node_in_group("player")
			
			if player != null:
				var distance = global_position.distance_to(player.global_position)
				if distance <= interaction_range:
					player.click_animation(get_global_mouse_position())
					take_damage()

func take_damage():
	if health <= 0: return

	health -= 1

	if tap_sound: tap_sound.play()
	if type == BrickType.GEM_CLUSTER: spawn_gem()
	
	if health <= 0:
		handle_break()
	else:
		var anim_prefix = "gem_" if type == BrickType.GEM_CLUSTER else ""
		animated_sprite.play(anim_prefix + str(health))

func spawn_gem():
	if gem_scene:
		var gem = gem_scene.instantiate()
		get_parent().add_child(gem)
		gem.global_position = global_position
		
		if "is_popped" in gem: 
			gem.is_popped = true
		
		gem.velocity = Vector2(randf_range(-70, 70), -220)

func handle_break():
	if break_sound:
		break_sound.play()
	
	if $Area2D != null:
		$Area2D.queue_free() # Stop more clicks
	
	var break_anim = "gem_break" if type == BrickType.GEM_CLUSTER else "break"
	animated_sprite.play(break_anim)
	
	# Optional: let the animation finish before deleting the brick
	await animated_sprite.animation_finished
	queue_free()
