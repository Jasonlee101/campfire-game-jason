extends CanvasLayer

@onready var anim: AnimationPlayer = get_node_or_null("AnimationPlayer")

func fade_out():
	if anim:
		anim.play("fade_to_black")
		await anim.animation_finished

func fade_in():
	if anim:
		anim.play("fade_from_black")
		await anim.animation_finished

func white_flash():
	if anim:
		anim.play("white_flash")
		await anim.animation_finished

func reload_scene():
	await fade_out()
	Engine.time_scale = 1
	stats.reset_score()
	get_tree().reload_current_scene()
	fade_in() 
