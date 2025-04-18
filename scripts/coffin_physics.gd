extends RigidBody2D

class_name CoffinPhysics
@onready var hand = $Hand

@onready var audio_wood: AudioStreamPlayer2D = $"/root/TilemapTest/AudioWood"
@onready var audio_other: AudioStreamPlayer2D = $"/root/TilemapTest/AudioOther"


var dragging = false
var rotate_while_dragging = true
var drag_start = Vector2()
var drag_offset = Vector2()
var click_position = Vector2() # Stores the position on the object where the click occurred
var rotation_start = 0.0

# Reference to display component
var display_component = null

# Physics interpolation for smooth dragging
var previous_pos = Vector2()
var target_pos = Vector2()
var drag_factor = 10.0
var rotation_factor = 10.0

# Line drawing
var should_draw_line = false
var line_color = Color(45/255.0, 142/255.0, 70/255.0, 1) # White with some transparency
var line_width = 5.0

# Line visualization
var line_node = null
var canvas_layer = null

func _ready():
	hand.visible = false
	# Apply the initial rotation from rotation_start
	rotation = rotation_start

	input_pickable = true
	
	# Initialize positions
	previous_pos = global_position
	target_pos = global_position
	
	# Create a canvas layer to draw on top
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # High layer number to be on top
	add_child(canvas_layer)
	
	# Create a Line2D node for drawing the line
	line_node = Line2D.new()
	line_node.width = line_width
	line_node.default_color = line_color
	line_node.z_index = 100  # Make sure it's on top
	canvas_layer.add_child(line_node)
	line_node.hide()  # Hide initially

	display_component = find_display_component()

func find_display_component():
	for child in self.get_children():
		if child is Sprite2D and child.has_method("set_hover"):
			return child

	return null


func _on_input_event(_viewport, event, _shape_idx):
	# Handle mouse button events
	if event is InputEventMouseButton and Phase.instance.current_phase == "coffin":
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			# Start dragging
			if event.pressed:
				dragging = true
				Cursor.instance.set_cursor_sprite("cursor")
				print("set cursor sprite")
				should_draw_line = true
				drag_start = get_viewport().get_mouse_position()
				drag_offset = global_position - drag_start
				
				# Store the click position relative to the object's center
				click_position = get_local_mouse_position()
				
				# Show the line
				line_node.show()
				
				# We need to set input as handled to receive global input
				set_process_unhandled_input(true)

# Handle global input for detecting mouse release anywhere
func _unhandled_input(event):
	if dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# Stop dragging when mouse is released anywhere
			dragging = false
			should_draw_line = false
			Cursor.instance.set_cursor_sprite("hand")

			if display_component:
				display_component.set_hover(false)
			
			# Hide the line
			line_node.hide()
			hand.hide()
			
			
			# Stop processing global input until next drag
			set_process_unhandled_input(false)

func _physics_process(delta):
	if dragging:
		hand.visible = true
		hand.position = click_position
		var mouse_pos = get_global_mouse_position()
		
		if rotate_while_dragging:
			# Calculate desired rotation based on mouse movement
			var center_to_mouse = mouse_pos - global_position
			var center_to_click = click_position.rotated(rotation)
			
			# Determine the angle to rotate
			var target_angle = center_to_mouse.angle()
			var current_angle = center_to_click.angle()
			var angle_diff = target_angle - current_angle
			
			# Normalize the angle difference
			if angle_diff > PI:
				angle_diff -= 2 * PI
			elif angle_diff < -PI:
				angle_diff += 2 * PI
				
			# Apply angular velocity for rotation around the click point
			angular_velocity = angle_diff * rotation_factor 
			angular_velocity = clamp(angular_velocity, -rotation_factor*PI/4, rotation_factor*PI/4)
			
			# Calculate the position offset to maintain click position under mouse
			var rotated_click_pos = click_position.rotated(rotation)
			var target_pos = mouse_pos - rotated_click_pos
			
			# Apply velocity to keep the click point under the mouse
			var velocity = (target_pos - global_position) * drag_factor
			# Limit the maximum velocity
			if velocity.length() > 1000:
				velocity = velocity.normalized() * 1000
			linear_velocity = velocity
		else:
			# Standard dragging without rotation
			target_pos = mouse_pos + drag_offset
			var velocity = (target_pos - global_position) * drag_factor
			linear_velocity = velocity
	
	# Update the line position
	if should_draw_line:
		var world_click_pos = get_global_transform_with_canvas() * self.get_node('Hand').position
		var mouse_pos = get_viewport().get_mouse_position()
		
		# Calculate and set the hand rotation to face the mouse
		var direction = (mouse_pos - world_click_pos).normalized()
		var angle = atan2(direction.y, direction.x)
		# Adjust the angle by 90 degrees (PI/2) if the hand needs to point along the direction
		hand.rotation = angle - rotation + PI/2
		
		# Update line points
		line_node.clear_points()
		line_node.add_point(world_click_pos)
		line_node.add_point(mouse_pos)


func _on_body_entered(body: Node) -> void:
	if body is CoffinPhysics:
		var speed = linear_velocity.length()
		audio_wood.volume_db = lerp(-120, 0, clamp(speed, 0, 300) / 300.0)
		audio_wood.volume_db = randf_range(-18.0, -6.0)
		audio_wood.pitch_scale = randf_range(0.5, 4.0)
		audio_wood.play()
	else:
		audio_other.volume_db = randf_range(-18.0, -6.0)
		audio_other.pitch_scale = randf_range(0.4, 1.0)
		audio_other.play()
