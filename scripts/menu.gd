extends Control

@onready var difficulty_selector = $OptionButton
signal menu_dismissed

func _ready() -> void:
	difficulty_selector.focus_mode = Control.FOCUS_NONE
	difficulty_selector.clear()
	difficulty_selector.add_item("Easy")
	difficulty_selector.add_item("Normal")
	difficulty_selector.add_item("Hard")
	difficulty_selector.selected = 1
	_on_difficulty_changed(1)
	difficulty_selector.item_selected.connect(_on_difficulty_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_on_start_pressed()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Start"):
		_on_start_pressed()

func _on_start_pressed() -> void:
	emit_signal("menu_dismissed")

func _on_difficulty_changed(index: int) -> void:
	$Label.show()
	match index:
		0: Global.current_difficulty = Global.Difficulty.EASY 
		1: Global.current_difficulty = Global.Difficulty.NORMAL 
		2: Global.current_difficulty = Global.Difficulty.HARD  
