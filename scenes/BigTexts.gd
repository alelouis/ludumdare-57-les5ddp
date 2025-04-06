extends RichTextLabel

@export var shake_strength: float = 3.0
@export var shake_speed: float = 10.0
@export var pulse_speed: float = 4.0
@export var pulse_scale: float = 1.1
@export var lifetime: float = 5.0  # seconds before disappearing
@export var shrink_duration: float = 1.0  # how long it takes to shrink away

@onready var soft_text = $"../SoftText"
@onready var soft_text_shadow = $"../SoftTextShadow"

@onready var shaking_text = $"."
@onready var shaking_text_shadow = $"../RichTextLabelShadow"

@onready var cinematic_timer = $"../CinematicTimer"


var original_position: Vector2
var base_scale: Vector2
var time_alive: float = 0.0
var shrinking: bool = false
var shrink_timer: float = 0.0
 	
func _ready():
	soft_text.hide()
	soft_text_shadow.hide()	
	shaking_text.hide()
	shaking_text_shadow.hide()
	randomize()
	original_position = position
	base_scale = scale
	pivot_offset = size / 2  # This centers the pivot for shaking & scaling
	cinematic_timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	# Shaking
	if Phase.current_phase == 'cinematic' && !soft_text.visible: 
		soft_text.show()
		soft_text_shadow.show()
		cinematic_timer.start()
	elif Phase.current_phase != 'cinematic' && soft_text.visible:
		soft_text.hide()
		soft_text_shadow.hide()		
		
		
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
	
func _on_timer_timeout():
	if(Phase.current_phase == 'cinematic'):
		Phase.next_phase()
	
