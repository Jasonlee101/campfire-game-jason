extends StaticBody2D

@onready var timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D

@export var interaction_range: float = 50.0
@onready var player = get_tree().get_first_node_in_group('player')
var health = 3

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Use the 'event' parameter for better mouse detection
	if event is InputEventMouseButton and Input.is_action_just_pressed("mine") and event.pressed:
		if player == null:
			player = get_tree().get_first_node_in_group("player")
		if player != null:
			var distance = global_position.distance_to(player.global_position)
			if distance <= interaction_range:
				if health >= 1:
					timer.start()
					health -= 1 

func _process(_delta: float):
	if self.health >= 1:
		animated_sprite.play(str(health))
	else:
		animated_sprite.play('break')
	
func _on_timer_timeout() -> void:
	if health <= 0:
		queue_free()
