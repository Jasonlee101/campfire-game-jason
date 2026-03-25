extends Enemy

@export_group("Conker Behavior")
@export var chase_speed = 100.0
@export var chase_timeout = 3.0
@export var skid_duration = 0.5

var is_chasing = false
var is_skidding = false
var chase_timer = 0.0

@onready var player_detector = $PlayerDetector

func _init():
	speed = 20.0
	health = 5
	recoil = 30
	recoil_timer_length = 0.01
	gem_count = 3

func _ready():
	if player_detector:
		player_detector.add_exception(self)

func handle_behavior(delta):
	if is_dead or is_skidding:
		velocity.x = move_toward(velocity.x, 0, 400 * delta)
		return

	var can_see_player = false

	if player_detector and player_detector.is_colliding():
		var target = player_detector.get_collider()
		if target and target.is_in_group("player"):
			can_see_player = true
			is_chasing = true 
			chase_timer = chase_timeout

	if is_chasing and not can_see_player:
		chase_timer -= delta
		if chase_timer <= 0:
			is_chasing = false

	if is_chasing:
		animated_sprite.play("chase")
		var player_node = get_tree().get_first_node_in_group("player")

		if player_node:
			var dir_to_player = sign(player_node.global_position.x - global_position.x)
			if dir_to_player != 0 and dir_to_player != direction:
				start_skid()
		
		if is_on_wall():
			velocity.x = 0
		else:
			velocity.x = direction * chase_speed

	else:
		animated_sprite.play("walk")
		if is_on_wall() or (ray_cast and ray_cast.is_colliding()):
			_perform_flip()

		velocity.x = direction * speed

func start_skid():
	if is_skidding: return
	is_skidding = true
	animated_sprite.play("walk") # Skid using the walk animation
	
	await get_tree().create_timer(skid_duration).timeout
	
	if not is_dead:
		_perform_flip()
		is_skidding = false

func _perform_flip():
	super._perform_flip()
	if player_detector:
		player_detector.target_position.x = abs(player_detector.target_position.x) * direction
