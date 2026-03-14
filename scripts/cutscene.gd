extends CanvasLayer

signal finished

@export var slides: Array[Texture2D] = []
var current_slide = 0
var is_fading = false

func _ready() -> void:
	if slides.size() > 0:
		display_slide()
	else:
		finished.emit()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		advance()
	
func advance():
	SoundFX.play_click()
	if is_fading: return
	is_fading = true
	
	await SceneTransition.fade_out()
	current_slide += 1
	
	if current_slide >= slides.size():
		finished.emit()
	else:
		display_slide()
		
	SceneTransition.fade_in()
	is_fading = false

func display_slide():
	$TextureRect.texture = slides[current_slide]
	$Timer.start()
