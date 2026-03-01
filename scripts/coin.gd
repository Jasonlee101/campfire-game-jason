extends Area2D
@onready var game_manager: Node = %GameManager

func _on_body_entered(body):
	Stats.score += 1
	print("Your score is:", Stats.score)
	queue_free()
