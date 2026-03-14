extends Area2D

@onready var cutscene_scene: PackedScene = preload("res://scenes/cutscene.tscn")
@export var is_ending_trigger: bool = false
@onready var hint = $InteractionHint
@onready var end_music = $"end music"
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
	
	cutscene_instance.is_ending_cutscene = is_ending_trigger
		
	if cutscene_instance is Control:
		cutscene_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
	if new_cutscene_slides.size() > 0:
		cutscene_instance.slides = new_cutscene_slides
	
	cutscene_instance.process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().root.add_child(cutscene_instance)
	get_tree().paused = true
	
	await SceneTransition.fade_in()
	await cutscene_instance.finished
	await SceneTransition.fade_out()
	cutscene_instance.queue_free()
	get_tree().paused = false
	
	SceneTransition.process_mode = Node.PROCESS_MODE_INHERIT
	
	await SceneTransition.fade_in()
