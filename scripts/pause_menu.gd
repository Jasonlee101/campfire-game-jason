extends CanvasLayer

@onready var mute_button = $Mute 
@onready var resume_button = $Resume


func _ready():
	hide() 

	mute_button.pressed.connect(_on_mute_toggled)
	resume_button.pressed.connect(toggle_pause)
	update_mute_icon()

	var hud_pause_btn = get_tree().current_scene.find_child("PauseButton", true, false)
	if hud_pause_btn:
		hud_pause_btn.pressed.connect(toggle_pause)

func toggle_pause():
	SoundFX.play_click()
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

	if new_pause_state:
		AudioServer.set_bus_volume_db(0, -15.0)
	else:
		AudioServer.set_bus_volume_db(0, 0.0)

func _on_mute_toggled():
	SoundFX.play_click()
	var is_muted = mute_button.button_pressed 
	AudioServer.set_bus_mute(0, is_muted)
	
	if "is_muted" in Global:
		Global.is_muted = is_muted

func update_mute_icon():
	mute_button.button_pressed = AudioServer.is_bus_mute(0)

func _input(event):
	if event.is_action_pressed("pause"):
		SoundFX.play_click()
		toggle_pause()
