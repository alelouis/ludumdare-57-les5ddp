extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the button's pressed signal to our function
	var button = $VBoxContainer/Button
	if button:
		button.pressed.connect(_on_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Function that gets called when the button is pressed
func _on_button_pressed():
	CameraTarget.set_camera_target(CameraTarget.Target.RULES_FOCUS)