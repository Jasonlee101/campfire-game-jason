extends CanvasLayer

signal finished

@onready var animation_player = get_node_or_null("AnimationPlayer")
@onready var ending_animation = get_node_or_null("AnimatedSprite2D")
@export var slides: Array[Texture2D] = []
@export var is_ending_cutscene: bool = false

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
	# 1. NEW CHECK: If we are already on the ending screen, 
	# block all further input immediately.
	if current_slide >= slides.size() and is_ending_cutscene:
		return
		
	if is_fading: return
	is_fading = true
	
	SoundFX.play_click()
	await SceneTransition.fade_out()
	
	current_slide += 1
	
	if current_slide >= slides.size():
		if is_ending_cutscene:
			show_ending_screen()
		else:
			await SceneTransition.fade_in() 
			finished.emit()
			queue_free()
	else:
		display_slide()
		await SceneTransition.fade_in()
		is_fading = false

func show_ending_screen():
	$TextureRect.hide()
	
	if ending_animation:
		ending_animation.show()
		ending_animation.play("default")
	
	await SceneTransition.fade_in()
	is_fading = false

func display_slide():
	$TextureRect.texture = slides[current_slide]
	$Timer.start()
