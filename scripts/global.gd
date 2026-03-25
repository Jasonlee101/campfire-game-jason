extends Node

enum Difficulty { EASY, NORMAL, HARD }
var current_difficulty = Difficulty.NORMAL
var is_easy = false

var is_muted: bool = false
var has_finished_intro: bool = false

var has_checkpoint: = false
var last_checkpoint_pos: = Vector2.ZERO
var fog_save_offset: float = 0.0
var saved_fog_time: = 0.0

var input_history: String = ""
var max_history_length: int = 12
var is_god_mode: bool = false

var saved_gems: int = 0
var temp_gems: int = 0

var game_time: float = 0.0
var run_completed: bool = false

signal request_teleport(checkpoint_id: int)
signal god_mode_toggled(enabled: bool)

func _process(delta: float):
	if not run_completed:
		game_time += delta

func get_formatted_time() -> String:
	var minutes = int(game_time / 60)
	var seconds = int(game_time) % 60
	return "%02d:%02d" % [minutes, seconds]

func save_session_gems():
	saved_gems = temp_gems

func reset_to_last_save():
	temp_gems = saved_gems

func get_difficulty_settings():
	match current_difficulty:
		Difficulty.EASY:
			is_easy = true
			return {"hearts": 5, "fog_time": 200.0}
		Difficulty.NORMAL:
			return {"hearts": 3, "fog_time": 180.0}
		Difficulty.HARD:
			return {"hearts": 1, "fog_time": 157.0}

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		var key_text = OS.get_keycode_string(event.keycode).to_upper()
		if key_text.length() == 1 and ((key_text >= "A" and key_text <= "Z") or (key_text >= "0" and key_text <= "9")):
			input_history += key_text
			if is_god_mode: print(input_history)

			if input_history.length() > max_history_length:
				input_history = input_history.right(max_history_length)

			check_for_cheats()

func check_for_cheats():
	if is_god_mode:
		if "TELEPORT1" in input_history:
			request_teleport.emit(1)
			input_history = ""
		elif "TELEPORT2" in input_history:
			request_teleport.emit(2)
			input_history = ""
		elif "TELEPORT3" in input_history:
			request_teleport.emit(3)
			input_history = ""

	if "SUPER" in input_history:
		toggle_god_mode()
		input_history = ""

func toggle_god_mode():
	is_god_mode = !is_god_mode
	god_mode_toggled.emit(is_god_mode)
	print("GOD MODE: ", is_god_mode)
