extends Control

signal finished

@export var slides: Array[Texture2D] = []
var current_slide = 0
func _ready() -> void:
	if slides.size() > 0:
		display_slide()
	else:
		finished.emit()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		advance()
	
func advance():
	current_slide +=1
	if current_slide >= slides.size():
		finished.emit()
	else:
		display_slide()

func display_slide():
	$TextureRect.texture = slides[current_slide]
	$Timer.start()
