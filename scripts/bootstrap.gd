extends Node2D

@onready var menu_scene: PackedScene = preload("res://scenes/menu.tscn")
@onready var game_scene: PackedScene = preload("res://scenes/game.tscn")
@onready var cutscene_scene: PackedScene = preload("res://scenes/cutscene.tscn")

var menu_instance
var cutscene_instance
var game_started = false

func _ready() -> void:
	var mute_btn = preload("res://scenes/mute.tscn")
	add_child(mute_btn)
	if Global.has_finished_intro:
		load_game_directly()
	else:
		$menumusic.play()
		menu_instance = menu_scene.instantiate() 
		add_child(menu_instance) 
		menu_instance.menu_dismissed.connect(_on_menu_dismissed)
 
func _on_menu_dismissed() -> void:
	if game_started: return
	game_started = true
	
	SoundFX.play_click()
	await SceneTransition.fade_out()
	
	if is_instance_valid(menu_instance):		
		menu_instance.queue_free()
		
	cutscene_instance = cutscene_scene.instantiate()
	add_child(cutscene_instance)
	cutscene_instance.finished.connect(_on_cutscene_finished)
	
	SceneTransition.fade_in()
	
func _on_cutscene_finished() -> void:
	$menumusic.stop()
	$Music.play()
	Global.has_finished_intro = true
	
	
	if is_instance_valid(cutscene_instance): 
		cutscene_instance.queue_free() 
  
	load_game_directly()

func load_game_directly() -> void:
	$Music.play()
	var game_node = game_scene.instantiate() 
	add_child(game_node) 
