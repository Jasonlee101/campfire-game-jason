extends Node2D

@onready var menu_scene: PackedScene = preload("res://scenes/menu.tscn")
@onready var game_scene: PackedScene = preload("res://scenes/game.tscn")
@onready var cutscene_scene: PackedScene = preload("res://scenes/cutscene.tscn")

var menu_instance
var cutscene_instance
var game_started = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Game started, loading title screen...")
	menu_instance = menu_scene.instantiate()
	add_child(menu_instance)
	
	menu_instance.menu_dismissed.connect(_on_menu_dismissed)

func _on_menu_dismissed() -> void:
	if game_started: return
	game_started = true
	print("Bootstrap: Signal recieved! Loading Cutscene...")
	if is_instance_valid(menu_instance):		
		menu_instance.queue_free()
	
	
	
	cutscene_instance = cutscene_scene.instantiate()
	add_child(cutscene_instance)
	
	cutscene_instance.finished.connect(_on_cutscene_finished)
	
func _on_cutscene_finished() -> void:
	print("cutscene finished")
	if is_instance_valid(cutscene_instance):
		cutscene_instance.queue_free()
	
	var game_node = game_scene.instantiate()
	add_child(game_node)
	print("loading game")
