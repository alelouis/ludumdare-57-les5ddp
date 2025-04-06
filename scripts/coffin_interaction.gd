extends CollisionPolygon2D

# Reference to parent rigidbody and coffin data
var rigidbody = null
var coffin_data = null

# Tooltip
var tooltip_node = null

# Reference to display component
var display_component = null

# Global tooltip tracking
static var active_tooltips = []

func _ready():
	# Get parent rigidbody
	rigidbody = get_parent()
	if not rigidbody is RigidBody2D:
		push_error("CoffinInteraction must be attached to a CollisionShape2D that is a child of a RigidBody2D")
		return
	
	# Make sure the rigidbody is set to handle input
	
	# Connect signals
	rigidbody.connect("mouse_entered", _on_mouse_entered)
	rigidbody.connect("mouse_exited", _on_mouse_exited)
	rigidbody.connect("tree_exiting", _on_coffin_deleted)
	
	# Find the coffin data node
	coffin_data = find_coffin_data()
	
	# Find the display component
	display_component = find_display_component()
	
	# Let's wait a short moment to make sure the physics script has created its canvas layer
	get_tree().create_timer(0.1).timeout.connect(create_tooltip)

func find_display_component():
	# Look for the Sprite2D with coffin_display.gd script in the rigidbody's children
	if rigidbody:
		for child in rigidbody.get_children():
			if child is Sprite2D and child.has_method("set_hover"):
				return child
		
		# Look one level deeper if needed
		for child in rigidbody.get_children():
			for grandchild in child.get_children():
				if grandchild is Sprite2D and grandchild.has_method("set_hover"):
					return grandchild
	
	return null

func _on_coffin_deleted():
	# Called when the coffin is being removed (i.e., when merging)
	if tooltip_node and tooltip_node.visible:
		tooltip_node.hide()
	
	# Make sure hover effect is removed
	if display_component:
		display_component.set_hover(false)

func find_coffin_data():
	# Look for a CoffinData node in parent's siblings
	var parent_of_rigidbody = rigidbody.get_parent()
	
	# Check if there's a CoffinData script attached to a sibling
	if parent_of_rigidbody.has_method("get_full_name"):
		return parent_of_rigidbody
	
	# Look for siblings of rigidbody's parent
	for child in parent_of_rigidbody.get_children():
		if child.has_method("get_full_name"):
			return child
			
	# Not found
	return null
	
func create_tooltip():
	# Get the existing canvas layer from the rigidbody if it exists
	var existing_canvas_layer = null
	for child in rigidbody.get_children():
		if child is CanvasLayer:
			existing_canvas_layer = child
			break
	
	if not existing_canvas_layer:
		existing_canvas_layer = get_tree().root
		
	# Create a Label for the tooltip
	tooltip_node = Label.new()
	tooltip_node.add_theme_font_size_override("font_size", 22)  # Increased size for better visibility
	tooltip_node.add_theme_color_override("font_color", Color(172.0/255.0, 187.0/255.0, 240.0/255.0, 1))  # Yellow for better visibility
	tooltip_node.add_theme_color_override("font_outline_color", Color(27.0/255.0, 37.0/255.0, 63.0/255.0, 0.6))
	tooltip_node.add_theme_constant_override("outline_size", 16)  # Thicker outline
	tooltip_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_node.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM # Bottom alignment since anchor is at bottom
	tooltip_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Make tooltip wider to handle longer dates without wrapping
	var viewport_size = get_viewport_rect().size
	tooltip_node.position = Vector2(viewport_size.x / 2 - 225, 30)
	tooltip_node.size = Vector2(450, 80)  # Wider for longer dates
	
	# Add to scene tree directly for maximum visibility
	get_tree().root.add_child(tooltip_node)
	
	# Store reference in static array for potential cleanup
	active_tooltips.append(tooltip_node)
	
	# Connect to tree_exiting to remove from active_tooltips when deleted
	tooltip_node.tree_exiting.connect(func(): _on_tooltip_deleted(tooltip_node))
	
	tooltip_node.hide()  # Hide initially

func _on_tooltip_deleted(tooltip):
	# Remove from active tooltips when the tooltip node is deleted
	if active_tooltips.has(tooltip):
		active_tooltips.erase(tooltip)

# Static method to hide all tooltips (can be called from anywhere)
static func hide_all_tooltips():
	for tooltip in active_tooltips:
		if tooltip and is_instance_valid(tooltip):
			tooltip.hide()

func _exit_tree():
	# Clean up our tooltip when this node is removed
	if tooltip_node and is_instance_valid(tooltip_node):
		tooltip_node.queue_free()
		
	# Remove from active tooltips
	if active_tooltips.has(tooltip_node):
		active_tooltips.erase(tooltip_node)

func _process(_delta):
	# Update tooltip position to follow mouse
	if tooltip_node and tooltip_node.visible:
		var mouse_pos = get_global_mouse_position()
		
		# Position tooltip ABOVE the cursor
		# Calculate height needed to show all text
		var num_people = 1
		if coffin_data and coffin_data.people:
			num_people = coffin_data.people.size()
		
		var tooltip_height = 25 + (num_people * 30)
		
		# Position tooltip with bottom edge at cursor position
		tooltip_node.position = Vector2(mouse_pos.x - 225, mouse_pos.y - tooltip_height - 15) # 15px gap from cursor
		
		# Make sure tooltip doesn't go off the top of the screen

func _on_mouse_entered():
	# Visual feedback
	if Phase.current_phase == "coffin":
		if rigidbody:
			rigidbody.modulate = Color(1.2, 1.2, 1.2)  # Slightly brighter
		
		# Activate hover effect on display component
		if display_component:
			display_component.set_hover(true)
		
		# Show tooltip if data is available
		if coffin_data and tooltip_node:
			# Get the full text to display
			var title = coffin_data.get_full_name()
			var detailed_text = coffin_data.get_detailed_text()
			
			# Set tooltip text
			tooltip_node.text = detailed_text
			
			# Adjust tooltip size based on number of people
			var num_people = coffin_data.people.size()
			tooltip_node.size = Vector2(450, 25 + (num_people * 20))  # Wider tooltip
			
			# Show the tooltip
			tooltip_node.show()

func _on_mouse_exited():
	# Reset visual feedback
	if Phase.current_phase == "coffin":
		if rigidbody:
			rigidbody.modulate = Color(1, 1, 1)  # Normal color

		if rigidbody:
			if not rigidbody.dragging:
				display_component.set_hover(false)
		
		# Hide tooltip
		if tooltip_node:
			tooltip_node.hide() 
