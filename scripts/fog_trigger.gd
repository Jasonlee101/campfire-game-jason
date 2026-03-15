extends Area2D
@export var fog_to_activate: Area2D
func _ready():
	# Connect the signal so the script knows when someone walks in
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var settings = Global.get_difficulty_settings()
	var target_time = settings.fog_time
	var original_length = 180.0
	if body.is_in_group("player"):
		if fog_to_activate != null:
			fog_to_activate.show()
			var anim_player = fog_to_activate.get_node("AnimationPlayer")
			anim_player.speed_scale = original_length / target_time
			if anim_player:
				anim_player.play("fog down")
			queue_free()
		
