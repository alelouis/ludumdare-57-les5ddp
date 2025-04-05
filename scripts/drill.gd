extends RigidBody2D
@onready var drag_sound := $DrillSound
@onready var fuel_bar = $"../CanvasLayer/FuelRect" # adjust path as needed
@export var ground: Ground

var is_dragging = false
var fade_speed = 2.0  # how fast to fade out
var target_volume = 0.0
# Acceleration parameters
@export var max_mouse_force = 100.0
@export var mouse_acceleration = 33.0  # force/second

@export var max_down_force = 70.0
@export var down_acceleration = 20.0   # force/second
@export var up_restistance = 5 
@export var torque_strength = 80.0

@export var isDrilling = false

var current_mouse_force = 0.0
var current_down_force = 0.0

var terrain_force_multiplier = 1.0
var start_position


func _ready() -> void:
	start_position = global_position
	$GroundEraser.ground = ground
	$GroundEraser.fuel = fuel_bar

func _unhandled_input(event):
	
	if isDrilling and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
		if not is_dragging:
			# Reset when mouse is released
			current_mouse_force = 0.0
			current_down_force = 0.0
			target_volume = -80.0  # fade out target (silent)
		else:
			# Restore default damping while dragging
			linear_damp = 2.0
			angular_damp = 2.0
			drag_sound.volume_db = -10  # start volume (adjust to your liking)
			target_volume = -10.0
			if not drag_sound.playing:
				drag_sound.play()

func _physics_process(delta):
	if is_dragging and isDrilling and fuel_bar.current_fuel != 0.0:
		# 👆 Accelerate toward max force
		current_mouse_force = min(current_mouse_force + mouse_acceleration * delta, max_mouse_force)
		current_down_force = min(current_down_force + down_acceleration * delta, max_down_force)

		# 💨 Apply force toward mouse
		var mouse_pos = get_global_mouse_position()
		var direction = mouse_pos - global_position
		if direction.y < 0:
			direction.y = direction.y - up_restistance  # prevent pulling upward
			
		
		apply_central_force(direction.normalized() * current_mouse_force * terrain_force_multiplier)
  		# Clamp target angle within the limits
		# ⬇️ Apply force downward
		apply_central_force(Vector2.DOWN * current_down_force)

		# 🌀 Rotate toward mouse
		var desired_angle = direction.angle()
		  		# Clamp target angle within the limits
		var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
		apply_torque(angle_diff * torque_strength)
		
		 # Smoothly fade volume
	if drag_sound.playing:
		drag_sound.volume_db = lerp(drag_sound.volume_db, target_volume, fade_speed * delta)

		# Stop playback when volume is close to silence
		if target_volume <= -70 and drag_sound.volume_db <= -70:
			drag_sound.stop()

	
func change_terrain_force_multiplier(current_terrain):
	match current_terrain:
		"mud":
			terrain_force_multiplier = 6.0
		"ice":
			terrain_force_multiplier = 1.5
		"boost":
			terrain_force_multiplier = 2.0
		_:
			terrain_force_multiplier =  1.0
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		reset_drill()
	if event is InputEventKey and event.pressed and event.keycode == KEY_D:
		isDrilling = !isDrilling
		if !isDrilling:
			is_dragging = false

func reset_drill():
	is_dragging = false
	fuel_bar.current_fuel = 100
	fuel_bar.update_bar()
	global_position = start_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	rotation = 0.0
	sleeping = false  # wake it up just in case
	print("Drill reset to starting position.")
