extends ColorRect

class_name DrillFuel

@export var max_fuel := 100.0
@export var delta := 0.1
@export var current_fuel := max_fuel
@onready var text_label = $"../RichTextLabel"
@onready var text_label_shadow = $"../RichTextLabelShadow"
@onready var coffin_generator = $"../../CoffinSpawner"

func _ready():
	Phase.phase_changed.connect(_on_phase_change)
	self.hide()
	update_bar()

func derive_fuel_from_coffins(n_coffins: int):
	
	var fuel = n_coffins * 4.5
	return fuel

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
	if(current_fuel == 0.0) and Phase.current_phase == "drill":
		Phase.next_phase()
		text_label.show_text("Coffin' Time !!!")
		text_label_shadow.show_text("Coffin' Time !!!")
		
func _on_phase_change(): 
	if(Phase.current_phase == 'drill'):
		self.show()
		max_fuel = 100
