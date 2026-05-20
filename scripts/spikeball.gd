extends Node2D

@export_enum("UpDown", "LeftRight", "Still") var spikeball_type: String = "UpDown"
@export var SPEED = 60

var direction = -1
@onready var ray_cast_1 = $RayCast1
@onready var ray_cast_2 = $RayCast2

func _ready():
	if spikeball_type == "Still":
		ray_cast_1.enabled = false
		ray_cast_2.enabled = false
		return 

	ray_cast_1.enabled = true
	ray_cast_2.enabled = true
	
	if spikeball_type == "LeftRight":
		ray_cast_1.target_position = Vector2(-10, 0)
		ray_cast_2.target_position = Vector2(10, 0)
	elif spikeball_type == "UpDown":
		ray_cast_1.target_position = Vector2(0, -10)
		ray_cast_2.target_position = Vector2(0, 10)

func _process(delta):
	if spikeball_type == "Still":
		return 

	if direction == -1 and ray_cast_1.is_colliding():
		direction = 1
	elif direction == 1 and ray_cast_2.is_colliding():
		direction = -1

	if spikeball_type == "UpDown":
		position.y += direction * SPEED * delta
	elif spikeball_type == "LeftRight":
		position.x += direction * SPEED * delta
