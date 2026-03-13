extends Area2D

# 1. Choose the look in the inspector
@export_enum("middle", "left", "right") var spring_type: String = "middle"
@export var vertical_force: float = -400.0
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Set the correct idle animation based on the type
	animated_sprite.play(spring_type + "_idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.velocity.y = vertical_force
		play_boing()

func play_boing():
	# Play the specific boing animation if you have one
	var anim_name = spring_type + "_boing"
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
		# Wait for it to finish then go back to idle
		await animated_sprite.animation_finished
		animated_sprite.play(spring_type + "_idle")
