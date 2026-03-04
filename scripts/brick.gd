extends StaticBody2D

@onready var timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D
@onready var tap_sound = $TapSound
@onready var break_sound = $BreakSound
@onready var animation_player = $AnimationPlayer
@onready var area_2d = $Area2D
var health = 3

@export var interaction_range: float = 50.0
@onready var player = get_tree().get_first_node_in_group('player')


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	# Use the 'event' parameter for better mouse detection
	if event is InputEventMouseButton and Input.is_action_just_pressed("mine") and event.pressed:
		if health >= 1:
			if player == null:
				player = get_tree().get_first_node_in_group("player")
			if player != null:
				var distance = global_position.distance_to(player.global_position)
				if distance <= interaction_range:
					tap_sound.play()
					print(health)
					health -= 1 

func _process(_delta: float):
	if health >= 1:
		animated_sprite.play(str(health))
	else:
		if area_2d:                               
			area_2d.queue_free()
			area_2d = null
			
		animated_sprite.play('break')
		animation_player.play('break')
