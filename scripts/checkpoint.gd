extends Area2D

@export var fog_to_activate: Area2D
@export var fog_time_margin: float = 3.0 

@onready var animated_sprite = $AnimatedSprite2D
@onready var label = $Label
@onready var save_sound = $SaveSound

var is_active = false
var player_in_range = false

func _ready():
	if Global.has_checkpoint and Global.last_checkpoint_pos == global_position:
		is_active = true
		animated_sprite.play("active")

		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = global_position

		if fog_to_activate != null:
			var anim_player = fog_to_activate.get_node("AnimationPlayer")
			if anim_player:
				anim_player.play("fog down")
				anim_player.seek(Global.saved_fog_time, true)
	else:
		animated_sprite.play("active") 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"): 
		activate_checkpoint()
		if SceneTransition.has_method("white_flash"):
			print('flash')
			SceneTransition.white_flash()
		flash_white()

func activate_checkpoint():
	is_active = true
	Global.last_checkpoint_pos = global_position
	Global.has_checkpoint = true

	stats.save_score()

	if fog_to_activate != null:
		var anim_player = fog_to_activate.get_node("AnimationPlayer")
		if anim_player:
			Global.saved_fog_time = max(0.0, anim_player.current_animation_position - fog_time_margin)

	animated_sprite.play("activating")
	show_save_message()
	save_sound.play()

	await animated_sprite.animation_finished
	animated_sprite.play("active")

func show_save_message():
	label.modulate.a = 0
	label.visible = true
	label.position.y = -50
	var tween = create_tween()
	tween.tween_property(label, "position:y", -70, 1.0).set_trans(Tween.TRANS_SINE)
	var fade_tween = create_tween()
	fade_tween.tween_property(label, "modulate:a", 1.0, 0.2)
	fade_tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(1.5)

func flash_white():
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(10, 10, 10, 1), 0.1)
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.2)
