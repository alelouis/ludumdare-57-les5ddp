extends ColorRect

@export var max_fuel := 100.0
@export var delta := 0.1
@export var current_fuel := max_fuel

func _ready():
	update_bar()

func drain(amount: float):
	current_fuel = clamp(current_fuel - amount * delta, 0.0, max_fuel)
	update_bar()

func refill(amount: float):
	current_fuel = clamp(current_fuel + amount, 0.0, max_fuel)
	update_bar()

func update_bar():
	# Update width
	var percent := current_fuel / max_fuel
	size.y = 400 * percent  # Assuming full bar is 200px

	# Update color
	if percent > 0.6:
		color = Color(0.0, 1.0, 0.0)  # Green
	elif percent > 0.3:
		color = Color(1.0, 1.0, 0.0)  # Yellow
	else:
		color = Color(1.0, 0.0, 0.0)  # Red
