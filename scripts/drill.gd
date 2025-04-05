extends RigidBody2D
@onready var drag_sound := $DrillSound

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

var current_mouse_force = 0.0
var current_down_force = 0.0

var torque_strength = 80.0
# Limit angles (in radians)
var min_angle = deg_to_rad(-45)  # left limit
var max_angle = deg_to_rad(45)   # right limit

func _ready() -> void:
	$GroundEraser.ground = ground

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
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
	if is_dragging:
		# 👆 Accelerate toward max force
		current_mouse_force = min(current_mouse_force + mouse_acceleration * delta, max_mouse_force)
		current_down_force = min(current_down_force + down_acceleration * delta, max_down_force)

		# 💨 Apply force toward mouse
		var mouse_pos = get_global_mouse_position()
		var direction = mouse_pos - global_position
		if direction.y < 0:
			direction.y = direction.y - up_restistance  # prevent pulling upward
		apply_central_force(direction.normalized() * current_mouse_force)
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
