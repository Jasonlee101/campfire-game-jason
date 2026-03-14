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
	if is_fading: return
	is_fading = true
	
	SoundFX.play_click()
	await SceneTransition.fade_out()
	
	current_slide += 1
	
	if current_slide >= slides.size():
		if is_ending_cutscene:
			show_ending_screen()
		else:
			# FIX: Fade back in so the player can see the game!
			await SceneTransition.fade_in() 
			finished.emit()
			queue_free()
	else:
		display_slide()
		await SceneTransition.fade_in() # Ensure this is awaited
		is_fading = false

func show_ending_screen():
	# Hide the static image
	$TextureRect.hide()
	
	# Show and play your animation (make sure this node is in your tscn)
	if ending_animation:
		ending_animation.show()
		ending_animation.play("default") # or your specific anim name
	
	await SceneTransition.fade_in()
	
	# Optional: Wait a few seconds before fully finishing
	await get_tree().create_timer(3.0).timeout
	finished.emit()
	# If you want to go back to the menu:
	# get_tree().change_scene_to_file("res://scenes/menu.tscn")

func display_slide():
	$TextureRect.texture = slides[current_slide]
	$Timer.start()
