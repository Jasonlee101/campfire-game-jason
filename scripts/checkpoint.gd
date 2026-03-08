extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Save state
		Global.last_checkpoint_pos = global_position
		Global.has_checkpoint = true
		
		var fog_node = get_tree().get_first_node_in_group("fog")
		if fog_node:
			var anim_player = fog_node.get_node("AnimationPlayer")
			Global.fog_save_offset = anim_player.current_animation_position
			print("Checkpoint: Saved! Fog time is: ", Global.fog_save_offset)
			
