extends Area2D

@export var spring_force: float = -600.0 # Stronger than a normal jump
@onready var animated_sprite = $AnimatedSprite2D
@onready var boing_sound = $AudioStreamPlayer2D

func _ready():
	# Connect the signal
	body_entered.connect(_on_body_entered)
	animated_sprite.play("idle")

func _on_body_entered(body):
	if body.is_in_group("player"):
		# 1. Launch the player!
		# We access the player's velocity directly
		body.velocity.y = spring_force
		
		# 2. Feedback
		animated_sprite.play("boing")
		if boing_sound:
			boing_sound.play()
		
		# 3. Handle the animation reset
		if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
			animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if animated_sprite.animation == "boing":
		animated_sprite.play("idle")
