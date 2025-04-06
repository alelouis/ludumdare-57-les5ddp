extends Area2D

class_name AboveGroundCoffinDetector

static var instance: AboveGroundCoffinDetector
var bodies_above_ground = 0

func _ready() -> void:
	assert(not instance, "Deux instances de AboveGroundCoffinDetector")
	instance = self
	Phase.instance.phase_changed.connect(on_phase_changed)
	
func has_bodies():
	return bodies_above_ground > 0
	
func on_phase_changed():
	if Phase.instance.current_phase == "cinematic":
		pass

func _on_body_entered(body: Node2D) -> void:
	bodies_above_ground += 1
	print(bodies_above_ground)

func _on_body_exited(body: Node2D) -> void:
	bodies_above_ground -= 1
	print(bodies_above_ground)
