extends Label

func _process(_delta: float) -> void:
	# 1. Update the text
	text = "Score: %d" % Stats.score
