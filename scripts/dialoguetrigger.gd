extends Area2D

@export_multiline var dialogue_text: String = "Replace this text in the inspector!"

@onready var canvas_layer = $CanvasLayer
@onready var label = $CanvasLayer/TextureRect/Label # Updated path

func _ready() -> void:
	# Hide the UI when the game starts
	canvas_layer.hide()
	
	# Connect the collision signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player and the game isn't already paused
	if body.is_in_group("player") and not get_tree().paused:
		# 1. Set the text
		label.text = dialogue_text
		# 2. Show the UI
		canvas_layer.show()
		# 3. Pause the game!
		get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	# Only listen for input if the game is paused AND this specific canvas is visible
	if get_tree().paused and canvas_layer.visible:
		# Check for any key press or mouse click
		if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
			# 1. Unpause the game
			get_tree().paused = false
			# 2. Destroy this trigger so it doesn't happen again
			queue_free() 
			
			# Consume the input so the player doesn't accidentally swing their sword or jump
			get_viewport().set_input_as_handled()
