extends AnimatedSprite2D


func _on_brick_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	queue_free()
