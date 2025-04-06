extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# animation_player.play("to_day")
	Phase.phase_changed.connect(on_phase_changed)
	pass

func on_phase_changed():
	match Phase.current_phase:
		"cinematic":
			animation_player.play("to_day")
		"drill":
			animation_player.play("to_night")
