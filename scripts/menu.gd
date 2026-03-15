extends Control

@onready var difficulty_selector = $OptionButton
signal menu_dismissed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# This stops the OptionButton from opening when you hit Spacebar!
	difficulty_selector.focus_mode = Control.FOCUS_NONE
	difficulty_selector.clear()
	difficulty_selector.add_item("Easy")
	difficulty_selector.add_item("Normal")
	difficulty_selector.add_item("Hard")
	difficulty_selector.selected = 1
	difficulty_selector.item_selected.connect(_on_difficulty_changed)

# FIXED: Added the underscore so Godot actually runs this function!
func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		_on_start_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Make sure "Start" is mapped in your Input Map (Project -> Project Settings -> Input Map)
	if Input.is_action_just_pressed("Start"):
		_on_start_pressed()

func _on_start_pressed() -> void:
	print("Starting game...") # Debug check 
	emit_signal("menu_dismissed")

func _on_difficulty_changed(index: int) -> void:
	# Prevent them from selecting the "Please Select:" option to start the game
		
	$Label.show()
	match index:
		1: Global.current_difficulty = Global.Difficulty.EASY
		2: Global.current_difficulty = Global.Difficulty.NORMAL
		3: Global.current_difficulty = Global.Difficulty.HARD
