extends Area2D

@export_enum("middle") var spring_type: String = "middle"
@export var launch_velocity: Vector2 = Vector2(0, -400)

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound

func _ready():
	animated_sprite.play(spring_type + "_idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.apply_spring_launch(launch_velocity)
		play_boing()
		
		jump_sound.play()

func play_boing():
	var anim_name = spring_type + "_boing"
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
		await animated_sprite.animation_finished
		animated_sprite.play(spring_type + "_idle")
