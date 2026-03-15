extends Area2D # Must be Area2D
@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	var settings = Global.get_difficulty_settings()
	var target_time = settings.fog_time
	var original_length = 180.0
	anim_player.speed_scale = original_length / target_time
	
	# 2. If a checkpoint was saved, "Seek" to that exact second
	if float(Global.fog_save_offset) > 0.0:
		# The 'true' argument tells Godot to update the physics/visuals immediately
		anim_player.seek(Global.fog_save_offset, true)
		print("Fog: Restored to animation time ", Global.fog_save_offset)
