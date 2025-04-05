extends Label

@export var start_time: float = 61.0  # start from 60 seconds
@export var count_down: bool = true   # set to false to count up
@onready var end_button := $"../Button"  # adjust path if needed
var time_left: float

func _ready():
	time_left = start_time
	end_button.pressed.connect(_on_end_pressed)
	update_text()

func _process(delta: float) -> void:
	if count_down:
		time_left = max(0.0, time_left - delta)
	else:
		time_left += delta
	update_text()
	if count_down and time_left <= 0.0:
		on_timer_finished()

func update_text():
	text = format_time(time_left)

func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

func on_timer_finished():
	# Called once when timer hits 0
	modulate = Color.RED
	text = "TIME'S UP!"

func _on_end_pressed():
	time_left = 0.0
	update_text()
