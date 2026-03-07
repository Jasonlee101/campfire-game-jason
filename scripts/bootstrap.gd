extends Node2D

@onready var menu: PackedScene = preload("res://scenes/menu.tscn")
@onready var game_scene: PackedScene = preload("res://scenes/game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var menu_instance = menu.instantiate()
	add_child(menu_instance)
	
	menu_instance.connect("menu_dismissed", Callable(self, "_on_menu_dismissed"))

func _on_menu_dismissed() -> void:
	print("recieved on other end")
	var game_instance = game_scene.instantiate()
	add_child(game_instance)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
