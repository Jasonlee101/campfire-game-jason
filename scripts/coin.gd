extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var floor_checker = $RayCast2D 

var velocity = Vector2.ZERO
var gem_gravity = 400.0 
var being_collected = false
var is_on_floor = false

func _process(delta):
	if being_collected: return
	
	if not is_on_floor:
		# Apply gravity and movement
		velocity.y += gem_gravity * delta
		position += velocity * delta
		
		# NEW LOGIC: Only land if we are falling (velocity.y > 0)
		# This prevents the gem from "landing" while it's still jumping UP.
		if velocity.y > 0 and floor_checker.is_colliding():
			var collider = floor_checker.get_collider()
			# Make sure we aren't "landing" on the player or the brick itself
			if collider is TileMap or collider is StaticBody2D:
				land()

func land():
	is_on_floor = true
	velocity = Vector2.ZERO
	# Snap to the exact floor point
	global_position.y = floor_checker.get_collision_point().y - 5 

func _on_body_entered(body):
	if body.is_in_group("player") and not being_collected:
		collect()

func collect():
	being_collected = true
	stats.score += 1 
	if animated_sprite.sprite_frames.has_animation("sparkle"):
		animated_sprite.play("sparkle")
	animation_player.play("pickup")
