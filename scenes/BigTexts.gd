extends RichTextLabel

@export var shake_strength: float = 3.0
@export var shake_speed: float = 10.0
@export var pulse_speed: float = 4.0
@export var pulse_scale: float = 1.1
@export var lifetime: float = 5.0  # seconds before disappearing
@export var shrink_duration: float = 1.0  # how long it takes to shrink away

var original_position: Vector2
var base_scale: Vector2
var time_alive: float = 0.0
var shrinking: bool = false
var shrink_timer: float = 0.0
 	
func _ready():
	randomize()
	original_position = position
	base_scale = scale
	pivot_offset = size / 2  # This centers the pivot for shaking & scaling

func _process(delta: float) -> void:
	# Shaking
	var shake = Vector2(
		sin(Time.get_ticks_msec() / 100.0 * shake_speed),
		cos(Time.get_ticks_msec() / 100.0 * shake_speed * 0.75)
	) * shake_strength

	position = original_position + shake

	# Pulse (scale animation)
	var pulse = 1.0 + sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * 0.05
	scale = Vector2(pulse, pulse)
	
	time_alive += delta
	if time_alive >= lifetime:
		shrinking = true
		
	if shrinking:
		shrink_timer += delta
		var t = clamp(shrink_timer / shrink_duration, 0.0, 1.0)
		scale = base_scale * (1.0 - t)
		if t >= 1.0:
			hide()  # or queue_free()
		return
		
func show_text(new_text: String, duration := 6.0):
	text = new_text
	time_alive = 0.0
	shrinking = false
	shrink_timer = 0.0
	scale = base_scale
	show()
	lifetime = duration
	
