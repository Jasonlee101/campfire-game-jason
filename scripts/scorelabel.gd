extends Label

func _process(_delta: float) -> void:
	# 1. Update the text
	text = "Score: %d" % Stats.score
	
	# 2. DEBUG: This will flood your output, but it proves the script is running!
	print("Label is trying to show: ", text)
