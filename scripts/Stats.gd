extends Node
class_name stats

static var score: int = 0
static var saved_score: int = 0 

signal trigger_animation(anim_name: String)

static func save_score():
	saved_score = score

static func reset_score():
	score = saved_score
