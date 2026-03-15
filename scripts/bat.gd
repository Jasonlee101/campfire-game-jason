extends Node2D

@export var health: int = 3
@export var knockback_force: float = 20.0 # Adjust this in the Inspector
@export var interaction_range: float = 80.0
@export var chase_range: float = 150.0 # How close the player needs to be for the bat to track them

const SPEED = 60
const CHASE_SPEED = 35 # Slower speed when tracking the player
var direction = -1

@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	var is_chasing = false
	
	# Check if the player exists and is close enough
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= chase_range:
			is_chasing = true
			
			# Calculate the direction to the player and move towards them
			var dir_to_player = global_position.direction_to(player.global_position)
			position += dir_to_player * CHASE_SPEED * delta
			
			# Flip the sprite to face the player
			if dir_to_player.x < 0:
				animated_sprite.flip_h = true # Facing left
			elif dir_to_player.x > 0:
				animated_sprite.flip_h = false # Facing right

	# If the player is NOT close, do the normal up/down patrol
	if not is_chasing:
		if ray_cast_up.is_colliding():
			direction = 1
		if ray_cast_down.is_colliding():
			direction = -1
		
		position.y += direction * SPEED * delta 

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
