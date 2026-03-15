extends Area2D

@export_enum("move_hint", "jump_hint", "click_hint") var auto_play_anim: String = "move_hint"
@onready var bubble = $InstructionBubble

func _ready():
	# Ensure the bubble is invisible but active
	bubble.modulate.a = 0
	bubble.play(auto_play_anim)
	
	# Connect signals (if not already done in editor)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		fade_bubble(1.0) # Fade in

func _on_body_exited(body):
	if body.is_in_group("player"):
		fade_bubble(0.0) # Fade out

func fade_bubble(target_alpha: float):
	# Create a tween to smoothly change the transparency
	var tween = create_tween()
	tween.tween_property(bubble, "modulate:a", target_alpha, 0.3).set_trans(Tween.TRANS_SINE)
	
	# Optional: Make the bubble "float" up/down slightly while visible
	if target_alpha > 0:
		var float_tween = create_tween().set_loops()
		float_tween.tween_property(bubble, "position:y", -35, 1)
		float_tween.tween_property(bubble, "position:y", -30 , 1)
