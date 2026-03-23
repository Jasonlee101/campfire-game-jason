extends CanvasLayer

signal finished

@onready var animation_player = get_node_or_null("AnimationPlayer")
@onready var ending_animation = get_node_or_null("AnimatedSprite2D")
@onready var end_music = $end_music 

@export var slides: Array[Texture2D] = []
@export var is_ending_cutscene: bool = false

var current_slide = 0
var is_fading = false

func _ready() -> void:
	if slides.size() > 0: 
		display_slide()
		if is_ending_cutscene and end_music:
			end_music.volume_db = -20.0
			end_music.play()
	else: 
		finished.emit()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		advance()

func advance():
	if current_slide >= slides.size() and is_ending_cutscene: return
	if is_fading: return
	is_fading = true
	
	SoundFX.play_click()
	await SceneTransition.fade_out()
	current_slide += 1
	
	if current_slide >= slides.size():
		if is_ending_cutscene:
			show_ending_screen()
		else:
			$TextureRect.hide() 
			finished.emit()
			queue_free()
			await SceneTransition.fade_in() 
	else:
		display_slide()
		await SceneTransition.fade_in()
		is_fading = false

func show_ending_screen():
	$TextureRect.hide()
	if ending_animation:
		if not end_music.playing:
			end_music.play()
		
		var tween = create_tween()
		tween.tween_property(end_music, "volume_db", 0.0, 2.0).set_trans(Tween.TRANS_SINE)
		
		ending_animation.show()
		ending_animation.play("default")
	
	await SceneTransition.fade_in()
	is_fading = false

func display_slide():
	$TextureRect.texture = slides[current_slide]
	$Timer.start()
