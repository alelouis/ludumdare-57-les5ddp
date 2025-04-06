extends Node2D

var phases = ["drill", "coffin","cinematic"]
var current_phase = null
signal phase_changed(new_phase)

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
