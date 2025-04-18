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
	CameraTarget.instance.set_camera_target(CameraTarget.instance.Target.BURY_FOCUS)
	Phase.instance.next_phase()
	await get_tree().create_timer(0.8).timeout
	CameraTarget.instance.set_camera_target(CameraTarget.instance.Target.CURSOR)
	CameraTarget.instance.enable_margins()
	
	
