extends Label

func _process(_delta: float):
	text = "Score: %d" % Stats.score
