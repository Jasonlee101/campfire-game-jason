extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D # Reference the sprite

func _on_body_entered(body):
	if not body.dead: 
		stats.score += 1 
		
		if animated_sprite.sprite_frames.has_animation("sparkle"):
			animated_sprite.play("sparkle")
			print('playing')
		
		animation_player.play("pickup")
