extends Area2D

@onready var cutscene_scene: PackedScene = preload("res://scenes/cutscene.tscn")
@onready var hint = $InteractionHint

# Drag your 4 images into this array in the Inspector
@export var new_cutscene_slides: Array[Texture2D] = []

var player_in_zone = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	hint.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		hint.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = false
		hint.hide()
		
func _process(_delta):
	if player_in_zone and Input.is_action_just_pressed("interact"):
		start_interact_cutscene()
		
func start_interact_cutscene():
	hint.hide()
	
	# 1. TELL SCENE TRANSITION TO IGNORE PAUSE
	SceneTransition.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. Fade out the game world
	await SceneTransition.fade_out()
	
	# 3. Instantiate the cutscene
	var cutscene_instance = cutscene_scene.instantiate()
	if cutscene_instance is Control:
		cutscene_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if new_cutscene_slides.size() > 0:
		cutscene_instance.slides = new_cutscene_slides
	
	# 5. Set process mode so it works while game is paused
	cutscene_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 6. Add to tree and pause game
	get_tree().root.add_child(cutscene_instance)
	get_tree().paused = true
	
	# 7. Fade in to show the cutscene
	await SceneTransition.fade_in()
	
	# 8. Wait for the cutscene to finish
	await cutscene_instance.finished
	
	# 9. Cleanup and return to game
	await SceneTransition.fade_out()
	cutscene_instance.queue_free()
	get_tree().paused = false
	
	# 10. (Optional) Set SceneTransition back to normal, though ALWAYS is fine for UI
	SceneTransition.process_mode = Node.PROCESS_MODE_INHERIT
	
	await SceneTransition.fade_in()
