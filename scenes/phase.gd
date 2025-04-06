extends Node2D

var phases = ["drill", "coffin","cinematic"]
var current_phase = null
var current_level = 1

signal phase_changed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func next_phase():
	if current_phase == null:
		current_phase = phases[0]
	else:
		current_phase = phases[(phases.find(current_phase) + 1) % phases.size()]
	phase_changed.emit()
	
func next_level(): # Call after validation
	print("next level")
	current_level = current_level +1
	next_phase()
	CameraTarget.set_camera_target(CameraTarget.Target.BURY_FOCUS)
