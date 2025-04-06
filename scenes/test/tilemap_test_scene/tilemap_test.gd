extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CameraTarget.instance.disable_margins()
	CameraTarget.instance.set_camera_target(CameraTarget.instance.Target.MENU_FOCUS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_try_again_button_pressed() -> void:
	#await get_tree().create_timer(0.8).timeout
	await get_tree().process_frame
	get_tree().reload_current_scene()
	
