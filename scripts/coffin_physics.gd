extends RigidBody2D

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
var drag_factor = 1.0
var rotation_factor = 10.0

# Line drawing
var should_draw_line = false
var line_color = Color(1, 1, 1, 0.8) # White with some transparency
var line_width = 10.0

# Line visualization
var line_node = null
var canvas_layer = null

func _ready():
	# Apply the initial rotation from rotation_start
	rotation = rotation_start
	
	# Initialize positions
	previous_pos = global_position
	target_pos = global_position
	input_pickable = true
	
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
		print(child)
		if child is Sprite2D and child.has_method("set_hover"):
			return child

	return null


func _on_input_event(_viewport, event, _shape_idx):
	# Handle mouse button events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			# Start dragging
			if event.pressed:
				dragging = true
				should_draw_line = true
				drag_start = get_global_mouse_position()
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

			if display_component:
				display_component.set_hover(false)
			
			# Hide the line
			line_node.hide()
			
			# Stop processing global input until next drag
			set_process_unhandled_input(false)

func _physics_process(delta):
	if dragging:
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
			
			# Calculate the position offset to maintain click position under mouse
			var rotated_click_pos = click_position.rotated(rotation)
			var target_pos = mouse_pos - rotated_click_pos
			
			# Apply velocity to keep the click point under the mouse
			var velocity = (target_pos - global_position) * drag_factor
			linear_velocity = velocity
		else:
			# Standard dragging without rotation
			target_pos = mouse_pos + drag_offset
			var velocity = (target_pos - global_position) * drag_factor
			linear_velocity = velocity
	
	# Update the line position
	if should_draw_line:
		var world_click_pos = to_global(click_position)
		var mouse_pos = get_global_mouse_position()
		
		# Update line points
		line_node.clear_points()
		line_node.add_point(world_click_pos)
		line_node.add_point(mouse_pos)
