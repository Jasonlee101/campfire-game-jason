extends CanvasLayer

@onready var anim: AnimationPlayer = get_node_or_null("AnimationPlayer")

func fade_out():
	if anim:
		anim.play("fade_to_black")
		await anim.animation_finished
	else:
		print("Error: AnimationPlayer not found on SceneTransition!")

func fade_in():
	if anim:
		anim.play("fade_from_black")
		await anim.animation_finished
