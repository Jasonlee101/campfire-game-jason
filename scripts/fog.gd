extends Node2D

@export var speed = 15.0
var is_active = false

func _process(delta):
	if is_active:
		position.y += speed * delta

func activate():
	is_active = true
