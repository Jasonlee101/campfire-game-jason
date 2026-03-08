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
@onready var jump_sound = $JumpSound

func _ready() -> void:
	# If we have a saved checkpoint position, move the player there immediately
	if Global.has_checkpoint:
		global_position = Global.last_checkpoint_pos

func _physics_process(delta: float):
	if not is_on_floor(): # Add the gravity.
		velocity.y += gravity * delta

	if not dead:
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

func _unhandled_input(event: InputEvent) -> void:
	if dead: return

	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	if event.is_action_pressed("mine"):
		_perform_swing()

func _perform_swing():
	pickaxe_sprite.play("swing")
	await get_tree().create_timer(0.34).timeout
	pickaxe_sprite.play("idle")

func _process(_delta):
	hand_pivot.look_at(get_global_mouse_position()) 
	# Keep the pickaxe upright when aiming left
	var mouse_pos = get_global_mouse_position() 
	if mouse_pos.x < global_position.x:
		hand_pivot.scale.y = -1
	else:
		hand_pivot.scale.y = 1
