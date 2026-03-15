extends Control

@onready var difficulty_selector = $OptionButton
var selected = false
signal menu_dismissed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)
	difficulty_selector.add_item("Please Select:")
	difficulty_selector.add_item("Easy")
	difficulty_selector.add_item("Normal")
	difficulty_selector.add_item("Hard")
	
	difficulty_selector.selected = 0
	difficulty_selector.item_selected.connect(_on_difficulty_changed)

func input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Start"):
		_on_start_pressed()

func _on_start_pressed() -> void:
	if selected:
		emit_signal("menu_dismissed")

func _on_difficulty_changed(index: int) -> void:
	selected = true
	$Label.show()
	match index:
		1: Global.current_difficulty = Global.Difficulty.EASY
		2: Global.current_difficulty = Global.Difficulty.NORMAL
		3: Global.current_difficulty = Global.Difficulty.HARD
