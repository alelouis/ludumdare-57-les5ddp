extends Node2D

class_name Phase

static var instance: Phase

var phases = ["drill", "coffin","cinematic"]
var current_phase = null
var current_level = 1

signal phase_changed()

func _enter_tree() -> void:
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
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
	current_level = current_level +1
	current_phase = phases[2]
	phase_changed.emit()
	CameraTarget.instance.set_camera_target(CameraTarget.instance.Target.BURY_FOCUS)
