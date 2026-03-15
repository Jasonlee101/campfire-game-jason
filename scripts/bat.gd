extends CharacterBody2D # Changed from Node2D to CharacterBody2D

@export var health: int = 2
@export var knockback_force: float = 20.0
@export var interaction_range: float = 80.0
@export var chase_range: float = 150.0

const SPEED = 60.0
const CHASE_SPEED = 35.0
var direction = -1

@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D

# Changed from _process to _physics_process
func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	var is_chasing = false
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= chase_range:
			is_chasing = true
			
			var dir_to_player = global_position.direction_to(player.global_position)
			# Set the velocity instead of changing position directly
			velocity = dir_to_player * CHASE_SPEED
			
			if dir_to_player.x < 0:
				animated_sprite.flip_h = true
			elif dir_to_player.x > 0:
				animated_sprite.flip_h = false

	if not is_chasing:
		if ray_cast_up.is_colliding():
			direction = 1
		if ray_cast_down.is_colliding():
			direction = -1
		
		# Move straight up or down for the patrol
		velocity = Vector2(0, direction * SPEED)
		
	# This single line handles all wall collisions automatically!
	move_and_slide()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if health > 0:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				var distance = global_position.distance_to(player.global_position)
				if distance <= interaction_range:
					if player.has_method("click_animation"):
						player.click_animation()
					
					take_damage()

func take_damage():
	health -= 1

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var knock_dir = sign(global_position.x - player.global_position.x)
		if knock_dir == 0: knock_dir = 1 
		var tween = create_tween()
		tween.tween_property(self, "position:x", position.x + (knock_dir * knockback_force), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	if health <= 0:
		queue_free()
