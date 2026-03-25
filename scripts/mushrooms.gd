extends AnimatedSprite2D

@export_enum(
	"Small", 
	"Medium", 
	"Large", 
	'Long BL', 
	"Long BR", 'Long TL', 
	"Long TR"
	) var mushroom_type: String = "Medium"

func _ready():
	var anim_name = mushroom_type

	if sprite_frames.has_animation(anim_name):
		play(anim_name)
