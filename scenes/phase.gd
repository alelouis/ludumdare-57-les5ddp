extends Node2D

var phases = ["drill", "coffin","cinematic"]
var current_phase = null
var current_level = 1

signal phase_changed(new_phase)

# Called when the node enters the scene tree for the first time.
func _ready():
	current_phase = phases[0]
	print("current phase: ", current_phase)
	phase_changed.emit(current_phase)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func next_phase():
	print("next phase")
	current_phase = phases[(phases.find(current_phase) + 1) % phases.size()]
	print("current phase: ", current_phase)
	phase_changed.emit()
	
func next_level(): # Call after validation
	print("next level")
	current_level = current_level +1
	current_phase = phases[2] #cinematic phase 
	print("current phase: ", current_phase)
	phase_changed.emit()
