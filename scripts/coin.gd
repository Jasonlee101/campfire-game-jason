extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D

@export var gem_gravity = 400.0 
@export var is_popped: bool = false 

var being_collected = false

func _physics_process(delta):
	if being_collected or not is_popped: 
		return
	
	velocity.y += gem_gravity * delta
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and not being_collected:
		collect()

func collect():
	being_collected = true
	stats.score += 1 
	if animated_sprite.sprite_frames.has_animation("sparkle"):
		animated_sprite.play("sparkle")
	animation_player.play("pickup")
