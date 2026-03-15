extends Control

@onready var difficulty_selector = $OptionButton
var selected = false
signal menu_dismissed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# This stops the OptionButton from opening when you hit Spacebar!
	difficulty_selector.focus_mode = Control.FOCUS_NONE
	
	difficulty_selector.add_item("Please Select:")
	difficulty_selector.add_item("Easy")
	difficulty_selector.add_item("Normal")
	difficulty_selector.add_item("Hard")
	
	difficulty_selector.selected = 0
	difficulty_selector.item_selected.connect(_on_difficulty_changed)

# FIXED: Added the underscore so Godot actually runs this function!
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Make sure "Start" is mapped in your Input Map (Project -> Project Settings -> Input Map)
	if Input.is_action_just_pressed("Start"):
		_on_start_pressed()

func _on_start_pressed() -> void:
	if selected:
		print("Starting game...") # Debug check 
		emit_signal("menu_dismissed")
	else:
		print("Difficulty not selected!")

func _on_difficulty_changed(index: int) -> void:
	# Prevent them from selecting the "Please Select:" option to start the game
	if index == 0:
		selected = false
		return
		
	selected = true
	$Label.show()
	match index:
		1: Global.current_difficulty = Global.Difficulty.EASY
		2: Global.current_difficulty = Global.Difficulty.NORMAL
		3: Global.current_difficulty = Global.Difficulty.HARD
