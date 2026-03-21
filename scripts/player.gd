extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 900.0
const TERMINAL_VELOCITY = 300.0

var dead = false
var is_invulnerable = false
var max_health = 3
var current_health = 3
var direction = 1
var was_in_air = false

var upward_recoil = -350.0
var normal_recoil = 250.0

var full_heart_rect = Rect2(0, 0, 16, 16)
var empty_heart_rect = Rect2(16, 0, 16, 16)

@onready var slash = $Slash
@onready var animated_sprite = $AnimatedSprite2D
@onready var slash_detector = $SlashDetector
@onready var jump_sound = $Sound/JumpSound
@onready var damage_sound = $Sound/DamageSound

func _ready() -> void:
	Global.god_mode_toggled.connect(_on_god_mode_toggled)
	var settings = Global.get_difficulty_settings() 
	max_health = settings.hearts
	current_health = max_health 
	
	if slash_detector: slash_detector.add_exception(self)
	slash.animation_finished.connect(func(): slash.visible = false)

	update_heart_ui()

func _on_god_mode_toggled(enabled: bool):
	modulate = Color(2.0, 1.7, 0.0) if enabled else Color(1, 1, 1)

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)

	if not dead:
		direction = Input.get_axis("move_left", "move_right")  
		
		if direction > 0: animated_sprite.flip_h = false
		elif direction < 0: animated_sprite.flip_h = true

		if is_on_floor() and was_in_air: 
			if not animated_sprite.animation.begins_with("slash"):
				animated_sprite.play("land")

		was_in_air = not is_on_floor()

		var is_slashing = animated_sprite.animation.begins_with("slash") and animated_sprite.is_playing()
		var is_landing = animated_sprite.animation == "land" and animated_sprite.is_playing()

		if not is_slashing and not is_landing:
			if not is_on_floor():
				if velocity.y < 0:
					animated_sprite.play("jump") 
				else:
					animated_sprite.play("fall")
			elif direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")

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
		perform_slash()

func perform_slash():
	var input_v = Input.get_axis("ui_up", "ui_down")
	var input_h = Input.get_axis("move_left", "move_right")
	var slash_dir = Vector2.ZERO
	
	if input_v > 0.5 and not is_on_floor():
		slash_dir = Vector2.DOWN
	elif input_v < -0.5:
		slash_dir = Vector2.UP
	elif abs(input_h) > 0.1:
		slash_dir = Vector2.LEFT if input_h < 0 else Vector2.RIGHT
	else:
		slash_dir = Vector2.LEFT if animated_sprite.flip_h else Vector2.RIGHT

	if input_h != 0:
		animated_sprite.play("slash_move")
	else:
		animated_sprite.play("slash")

	slash.visible = true
	slash.play("slash")
	
	if slash_dir.x != 0:
		animated_sprite.flip_h = (slash_dir.x < 0)

	slash.rotation_degrees = 0
	slash.flip_h = false

	match slash_dir:
		Vector2.DOWN:
			slash.position = Vector2(0, 12)
			slash.rotation_degrees = 90
		Vector2.UP:
			slash.position = Vector2(0, -22)
			slash.rotation_degrees = -90
		Vector2.LEFT:
			slash.position = Vector2(-12, -8)
			slash.flip_h = true
		Vector2.RIGHT:
			slash.position = Vector2(12, -8)
			slash.flip_h = false

	slash_detector.position = slash.position

	slash_detector.force_shapecast_update()
	if slash_detector.is_colliding():
		apply_recoil(slash_dir)

		for i in range(slash_detector.get_collision_count()):
			var target = slash_detector.get_collider(i)
			if target.has_method("take_damage"):
				target.take_damage()

func apply_recoil(dir: Vector2):
	if dir == Vector2.DOWN:
		velocity.y = upward_recoil 
	elif dir == Vector2.UP:
		velocity.y = -upward_recoil * 0.3 
	elif dir == Vector2.LEFT:
		velocity.x = normal_recoil
	elif dir == Vector2.RIGHT:
		velocity.x = -normal_recoil

func take_damage(amount: int = 1):
	if dead or is_invulnerable or Global.is_god_mode: return
	damage_sound.play()
	current_health = max(0, current_health - amount)
	update_heart_ui()
	if current_health <= 0: die()
	else: become_invulnerable(1.5)

func become_invulnerable(seconds: float):
	is_invulnerable = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.set_loops(int(seconds * 5))
	await get_tree().create_timer(seconds).timeout
	is_invulnerable = false
	modulate.a = 1.0

func update_heart_ui():
	var container = get_tree().root.find_child("HeartsContainer", true, false)
	if not container: return
	for i in range(container.get_child_count()):
		var heart = container.get_child(i)
		heart.visible = i < max_health
		heart.region_rect = full_heart_rect if i < current_health else empty_heart_rect

func die():
	dead = true
	animated_sprite.play("death")
