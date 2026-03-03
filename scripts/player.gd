extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dead = false
var swinging = false 
var direction = 0

@onready var animated_sprite = $AnimatedSprite2D
@onready var hand_pivot = $HandPivot
@onready var pickaxe_sprite = $HandPivot/Pickaxe
@onready var anim_player = $HandPivot/AnimationPlayer
@onready var timer = $Timer

func _physics_process(delta: float):
	
	if not is_on_floor(): # Add the gravity.
		velocity.y += gravity * delta

	if not dead:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("mine"):
			pickaxe_sprite.play("swing")
			await get_tree().create_timer(0.34).timeout
			pickaxe_sprite.play("idle")
		direction = Input.get_axis("move_left", "move_right")
		
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
			
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
			
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _process(_delta):
	hand_pivot.look_at(get_global_mouse_position()) 	# Make the pickaxe pivot point at mouse

	var mouse_pos = get_global_mouse_position() 	# Keep the pickaxe upright when aiming left
	if mouse_pos.x < global_position.x:
		hand_pivot.scale.y = -1
	else:
		hand_pivot.scale.y = 1
		
