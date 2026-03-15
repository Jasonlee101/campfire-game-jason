extends Node

enum Difficulty { EASY, NORMAL, HARD }
var current_difficulty = Difficulty.NORMAL
var is_muted: bool = false
var has_finished_intro: bool = false
var has_checkpoint: = false
var last_checkpoint_pos: = Vector2.ZERO
var fog_save_offset: float = 0.0
var saved_fog_time: = 0.0
var is_easy = false

func get_difficulty_settings():
	match current_difficulty:
		Difficulty.EASY:
			is_easy = true
			return {"hearts": 4, "fog_time": 200.0}
		Difficulty.NORMAL:
			return {"hearts": 3, "fog_time": 180.0}
		Difficulty.HARD:
			return {"hearts": 3, "fog_time": 157.0}
