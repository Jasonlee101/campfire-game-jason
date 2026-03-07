extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)
	print("menu started")


func input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()
		print("input recieved")
		

	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Start"):
		_on_start_pressed()
		print("input tried recieved")
	
func _on_start_pressed() -> void:
	emit_signal("menu_dismissed")
	print("input worked")
