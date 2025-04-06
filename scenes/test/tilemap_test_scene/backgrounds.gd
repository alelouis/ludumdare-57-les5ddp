extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var initialized = false

func _ready() -> void:
	# animation_player.play("to_day")
	Phase.instance.phase_changed.connect(on_phase_changed)
	pass

func on_phase_changed():
	match Phase.instance.current_phase:
		"cinematic":
			animation_player.play("to_day")
		"drill":
			if initialized:
				animation_player.play("to_night")
			else:
				initialized = true
