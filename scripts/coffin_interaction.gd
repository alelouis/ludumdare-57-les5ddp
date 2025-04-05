extends CollisionShape2D

# Reference to parent rigidbody and coffin data
var rigidbody = null
var coffin_data = null

# Tooltip
var tooltip_node = null

func _ready():
    # Get parent rigidbody
    rigidbody = get_parent()
    if not rigidbody is RigidBody2D:
        push_error("CoffinInteraction must be attached to a CollisionShape2D that is a child of a RigidBody2D")
        return
    
    # Make sure the rigidbody is set to handle input
    rigidbody.input_pickable = true
    
    # Connect signals
    rigidbody.connect("mouse_entered", _on_mouse_entered)
    rigidbody.connect("mouse_exited", _on_mouse_exited)
    
    # Find the coffin data node
    coffin_data = find_coffin_data()
    
    # Let's wait a short moment to make sure the physics script has created its canvas layer
    get_tree().create_timer(0.1).timeout.connect(create_tooltip)

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
    tooltip_node.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow for better visibility
    tooltip_node.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
    tooltip_node.add_theme_constant_override("outline_size", 3)  # Thicker outline
    tooltip_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    tooltip_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    tooltip_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    
    # Make tooltip bigger for two lines of text
    var viewport_size = get_viewport_rect().size
    tooltip_node.position = Vector2(viewport_size.x / 2 - 150, 30)
    tooltip_node.size = Vector2(300, 80)  # Taller for two lines
    
    # Add shadow
    tooltip_node.add_theme_constant_override("shadow_offset_x", 2)
    tooltip_node.add_theme_constant_override("shadow_offset_y", 2)
    tooltip_node.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
    
    # Add to scene tree directly for maximum visibility
    get_tree().root.add_child(tooltip_node)
    
    tooltip_node.hide()  # Hide initially

func _process(_delta):
    # Update tooltip position to follow mouse
    if tooltip_node and tooltip_node.visible:
        var mouse_pos = get_viewport().get_mouse_position()
        tooltip_node.position = Vector2(mouse_pos.x - 150, mouse_pos.y - 100)  # Adjusted for better visibility

func _on_mouse_entered():
    # Visual feedback
    if rigidbody:
        rigidbody.modulate = Color(1.2, 1.2, 1.2)  # Slightly brighter
    
    # Show tooltip if data is available
    if coffin_data and tooltip_node:
        var name = coffin_data.get_full_name()
        var date_range = coffin_data.get_date_range()
        
        # Format text with both name and dates
        var tooltip_text = name
        if not date_range.is_empty():
            tooltip_text += "\n" + date_range
            
        tooltip_node.text = tooltip_text
        tooltip_node.show()

func _on_mouse_exited():
    # Reset visual feedback
    if rigidbody:
        rigidbody.modulate = Color(1, 1, 1)  # Normal color
    
    # Hide tooltip
    if tooltip_node:
        tooltip_node.hide() 