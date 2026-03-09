extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var label = $Label
@onready var save_sound = $SaveSound

var is_active = false

func _ready():
	# On load, check if this is already the active checkpoint
	if Global.has_checkpoint and Global.last_checkpoint_pos == global_position:
		is_active = true
		animated_sprite.play("active") # Jump straight to the looping state
	else:
		animated_sprite.play("inactive")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_active:
		activate_checkpoint()

func activate_checkpoint():
	is_active = true

	Global.last_checkpoint_pos = global_position
	Global.has_checkpoint = true

	var fog_node = get_tree().get_first_node_in_group("fog")
	if fog_node:
		var anim_player = fog_node.get_node("AnimationPlayer")
		Global.fog_save_offset = anim_player.current_animation_position

	animated_sprite.play("activating")

	show_save_message()
	save_sound.play()

	await animated_sprite.animation_finished
	if animated_sprite.animation == "activating":
		animated_sprite.play("active")

func show_save_message():
	# Reset the label state
	label.modulate.a = 0     # Start fully transparent
	label.visible = true     # Make it exist
	label.position.y = -50   # Starting height
	
	# Create a Tween (Godot's animation tool for code)
	var tween = create_tween()
	
	# Move the label up 20 pixels over 1 second
	tween.tween_property(label, "position:y", -70, 1.0).set_trans(Tween.TRANS_SINE)
	
	# Fade the label in and then out
	# Parallel() means "do this at the same time as the movement above"
	var fade_tween = create_tween()
	fade_tween.tween_property(label, "modulate:a", 1.0, 0.2) # Fade in quick
	fade_tween.tween_interval(0.6)                          # Stay visible
	fade_tween.tween_property(label, "modulate:a", 0.0, 0.2) # Fade out quick
	
	# Hide the label when finished so it doesn't block clicks
	fade_tween.tween_callback(func(): label.visible = false)
