extends Area2D # Must be Area2D
@onready var anim_player = $AnimationPlayer

func _ready() -> void:

	
	# 2. If a checkpoint was saved, "Seek" to that exact second
	if float(Global.fog_save_offset) > 0.0:
		# The 'true' argument tells Godot to update the physics/visuals immediately
		anim_player.seek(Global.fog_save_offset, true)
		print("Fog: Restored to animation time ", Global.fog_save_offset)
