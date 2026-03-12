extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dead = false
var swinging = false 
var direction = 0
var is_invulnerable = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var hand_pivot = $HandPivot
@onready var pickaxe_sprite = $HandPivot/Pickaxe
@onready var anim_player = $HandPivot/AnimationPlayer
@onready var timer = $Timer
@onready var jump_sound = $JumpSound
@onready var click = $Click

func _ready() -> void:
	click.top_level = true
	# If we have a saved checkpoint position, move the player there immediately
	if Global.has_checkpoint:
		global_position = Global.last_checkpoint_pos + Vector2(0, -5)
		become_invulnerable(2.0)

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

	if event.is_action_pressed("minex"):
		_handle_directional_mining()

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

func click_animation(pos = null):
	if pos != null:
		# If a specific position was passed (from the mouse click), use it
		click.global_position = pos
	elif $MineRay.is_colliding():
		# If no position was passed, but the RayCast hit something, use that
		click.global_position = $MineRay.get_collision_point()
	else:
		# Fallback just in case
		click.global_position = get_global_mouse_position()
		
	click.play("click")
	# Clean way to reset the animation without a timer
	if not click.animation_finished.is_connected(_on_click_finished):
		click.animation_finished.connect(_on_click_finished)

func _on_click_finished():
	click.play("idle")

func _handle_directional_mining():
	var mine_dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):    # Or whatever your 'up' action is
		mine_dir = Vector2(0, -40)          # Up
	elif Input.is_action_pressed("ui_down"):
		mine_dir = Vector2(0, 40)           # Down
	else:
		if animated_sprite.flip_h:
			mine_dir = Vector2(-40, 0)      # Left
		else:
			mine_dir = Vector2(40, 0)       # Right

	# 2. Update the RayCast target
	$MineRay.target_position = mine_dir
	$MineRay.add_exception(self)
	# 3. Force the RayCast to update immediately so it doesn't wait for the next frame
	$MineRay.force_raycast_update()

	if $MineRay.is_colliding():
		var target = $MineRay.get_collider()
		_perform_swing()
		if target and target.has_method("take_damage"):
			click_animation()
			target.take_damage()

func become_invulnerable(seconds: float):
	is_invulnerable = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.3, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.set_loops(int(seconds * 5))
	
	await get_tree().create_timer(seconds).timeout
	is_invulnerable = false
	modulate.a = 1.0
