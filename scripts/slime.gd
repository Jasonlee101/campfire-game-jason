extends Node2D

@export var health: int = 3
@export var knockback_force: float = 20.0 # Adjust this in the Inspector
@export var interaction_range: float = 80.0
const SPEED = 60
var direction = -1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta 

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
		tween.tween_property(self, "position:x", position.x + (knock_dir * knockback_force), 0.15).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	flash_white()
	if health <= 0: die()

func flash_white():
	animated_sprite.modulate = Color(10, 10, 10) # Overbright white
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE

func die():
	queue_free()
