extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	print('body in')
	if body is CharacterBody2D:
		print("saved")
		Global.last_checkpoint_pos = global_position
		# If your fog script has a 'position' or 'progress' variable, save it here
		var fog_node = get_tree().get_first_node_in_group("fog")
		if fog_node:
		# We save the time (seconds) into the animation
			var anim_player = fog_node.get_node("AnimationPlayer")
			Global.fog_save_offset = anim_player.current_animation_position
			
		print("Checkpoint saved at fog time: ", Global.fog_save_offset)
