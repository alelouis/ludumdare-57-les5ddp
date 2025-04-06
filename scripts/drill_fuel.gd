extends ColorRect

class_name DrillFuel

@export var max_fuel := 100.0
@export var delta := 0.1
@export var current_fuel := 0.1
@onready var text_label = $"../RichTextLabel"
@onready var text_label_shadow = $"../RichTextLabelShadow"
@onready var coffin_generator = $"../../CoffinSpawner"
@onready var fuel_particle_effect = $CPUParticles2D
@onready var sprite_fuel_back = $"../Sprite2D"
@onready var sprite_fuel_front = $"../Sprite2D2"

func _ready():
	Phase.instance.phase_changed.connect(_on_phase_change)
	self.hide()
	sprite_fuel_back.hide()
	sprite_fuel_front.hide()
	update_bar()
	fuel_particle_effect.emitting = false


func derive_fuel_from_coffins(n_coffins: int):
	return n_coffins * 8

func drain(amount: float):
	current_fuel = clamp(current_fuel - amount * delta, 0.0, max_fuel)
	update_bar()

func update_bar():
	# Update width
	var percent := current_fuel / max_fuel
	size.y = 400 * percent  # Assuming full bar is 200px
	fuel_particle_effect.emitting = true
	fuel_particle_effect.position.y = size.y
	
	# Update color
	if percent > 0.6:
		color = Color(0.0, 1.0, 0.0)  # Green
	elif percent > 0.3:
		color = Color(1.0, 1.0, 0.0)  # Yellow
	else:
		color = Color(1.0, 0.0, 0.0)  # Red
	if(current_fuel == 0.0) and Phase.instance.current_phase == "drill":
		Phase.instance.next_phase()
	fuel_particle_effect.emitting = false

		
func _on_phase_change(): 
	if(Phase.instance.current_phase == 'drill'):
		self.show()
		sprite_fuel_back.show()
		sprite_fuel_front.show()

		coffin_generator.update_spawn_count()
		current_fuel += derive_fuel_from_coffins(coffin_generator.spawn_count)
		current_fuel = min(current_fuel,max_fuel)
		update_bar()
	if(Phase.instance.current_phase == 'coffin'):
		self.hide()
		sprite_fuel_back.hide()
		sprite_fuel_front.hide()
		fuel_particle_effect.emitting = false
