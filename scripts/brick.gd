extends StaticBody2D

@onready var timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D

@export var interaction_range: float = 50.0
@onready var player = get_tree().get_first_node_in_group('player')

func _on_ready() -> void:
	print("I'm a brick")

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Use the 'event' parameter for better mouse detection
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if player == null:
			player = get_tree().get_first_node_in_group("player")
		if player != null:
			var distance = global_position.distance_to(player.global_position)
			if distance <= interaction_range:
				timer.start()
				animated_sprite.play('break')
			else:
				print("Too far!")

func _on_timer_timeout() -> void:
	queue_free()
