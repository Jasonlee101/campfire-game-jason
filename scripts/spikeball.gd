extends Node2D


@export_enum(
	"UpDown", 
	"LeftRight"
	) var spikeball_type: String = "UpDown"
const SPEED = 60

var direction = -1
@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	if ray_cast_up.is_colliding():
		direction = 1
	if ray_cast_down.is_colliding():
		direction = -1
	if spikeball_type == "UpDown":
		position.y += direction * SPEED * delta 
	else:
		position.x += direction * SPEED * delta 
