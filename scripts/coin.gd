extends Area2D
@onready var game_manager: Node = %GameManager
@onready var animation_player = $AnimationPlayer
func _on_body_entered(body):
	Stats.score += 1
	animation_player.play("pickup")
