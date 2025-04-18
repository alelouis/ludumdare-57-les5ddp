extends AudioStreamPlayer

@export var intro_a: AudioStream
@export var intro_b: AudioStream

@export var drill_a: AudioStream
@export var drill_b: AudioStream

@export var cinematic_a: AudioStream
@export var cinematic_b: AudioStream

@export var lose_music: AudioStream

var next_stream: AudioStream

func _ready() -> void:
	stream = intro_a
	next_stream = intro_b
	play()
	Phase.instance.phase_changed.connect(on_phase_changed)
	self.finished.connect(on_finished)

func on_finished():
	if next_stream and next_stream != stream:
		stream = next_stream
	if stream != lose_music:
		play()
	
func on_phase_changed():
	match Phase.instance.current_phase:
		"drill":
			if stream != drill_a and stream != drill_b:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "volume_db", -60, 1)
				await tween.finished
				volume_db = 0
				stream = drill_a
				next_stream = drill_b
				play()
		"cinematic":
			if stream != lose_music and AboveGroundCoffinDetector.instance.has_bodies():
				var tween = get_tree().create_tween()
				tween.tween_property(self, "volume_db", -60, 1)
				await tween.finished
				volume_db = 0
				stream = lose_music
				next_stream = null
				play()
			if stream != cinematic_a and stream != cinematic_b and not AboveGroundCoffinDetector.instance.has_bodies():
				var tween = get_tree().create_tween()
				tween.tween_property(self, "volume_db", -60, 1)
				await tween.finished
				volume_db = 0
				stream = cinematic_a
				next_stream = cinematic_b
				play()
