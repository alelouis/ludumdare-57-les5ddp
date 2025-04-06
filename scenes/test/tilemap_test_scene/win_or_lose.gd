extends Node

@onready var above_ground_coffin_detector: AboveGroundCoffinDetector = $"../AboveGroundCoffinDetector"

func _ready() -> void:
	Phase.instance.phase_changed.connect(on_phase_changed)
	
func on_phase_changed():
	match Phase.instance.current_phase:
		"cinematic":
			if above_ground_coffin_detector.has_bodies():
				print("YOU LOSE !")
			else:
				print("YOU DONT LOSE YET")
