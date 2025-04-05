extends Sprite2D

# Sprite references for different occupancy counts
var coffin_sprites = {
	1: preload("res://assets/sprites/coffin_a1.png"),
	2: preload("res://assets/sprites/coffin_a2.png"),
	3: preload("res://assets/sprites/coffin_a3.png"),
	4: preload("res://assets/sprites/coffin_a4.png"),
	5: preload("res://assets/sprites/coffin_a5.png"),
	6: preload("res://assets/sprites/coffin_a6.png")
}

# Reference to coffin data
var coffin_data = null

# Shader for hover effect
var hover_shader = null
var normal_material = null
var hover_material = null
var is_hovered = false
var pulse_time = 0.0
var pulse_speed = 3.0  # Speed of the pulse effect
var pulse_intensity = 0.4  # Intensity of the glow

func _ready():
	# Find coffin data
	coffin_data = find_coffin_data()
	
	# Connect signal to update sprite when data changes
	if coffin_data:
		coffin_data.connect("data_updated", _on_coffin_data_updated)
	
	# Save the original material
	normal_material = material
	
	# Create the hover shader material
	setup_hover_shader()
	
	# Update sprite
	update_sprite()
	
	# Expand the sprite region to make room for the outline
	expand_sprite_region()

func setup_hover_shader():
	# Create a new shader material
	hover_material = ShaderMaterial.new()
	
	# Create the shader
	hover_shader = Shader.new()
	hover_shader.code = """
	shader_type canvas_item;
	
	uniform float outline_width : hint_range(1.0, 10.0) = 8.0;
	uniform vec4 outline_color : source_color = vec4(1.0, 0.8, 0.0, 1.0);
	uniform float pulse_value : hint_range(0.0, 1.0) = 0.0;
	
	void fragment() {
		vec4 col = texture(TEXTURE, UV);
		vec2 ps = TEXTURE_PIXEL_SIZE;
		
		// Calculate pulsating width
		float pulse_effect = 0.8 + 0.2 * sin(pulse_value * 6.28);
		float pulsating_width = outline_width * (0.8 + 0.4 * sin(pulse_value * 6.28));
		
		// Define the simple outline detection with pulsating width
		float a = texture(TEXTURE, UV + vec2(0.0, -pulsating_width) * ps).a;
		a += texture(TEXTURE, UV + vec2(-pulsating_width, 0.0) * ps).a;
		a += texture(TEXTURE, UV + vec2(0.0, pulsating_width) * ps).a;
		a += texture(TEXTURE, UV + vec2(pulsating_width, 0.0) * ps).a;
		
		// Add diagonal samples for better coverage
		float diag = pulsating_width * 0.7071; // sqrt(2)/2 to maintain consistent width
		a += texture(TEXTURE, UV + vec2(-diag, -diag) * ps).a;
		a += texture(TEXTURE, UV + vec2(diag, -diag) * ps).a;
		a += texture(TEXTURE, UV + vec2(-diag, diag) * ps).a;
		a += texture(TEXTURE, UV + vec2(diag, diag) * ps).a;
		
		// Create the outline effect - only where the current pixel is transparent
		// but surrounded by non-transparent pixels
		if (col.a < 0.1 && a > 0.0) {
			COLOR = vec4(outline_color.rgb, min(a, 1.0) * outline_color.a * pulse_effect);
		} else {
			COLOR = col;
		}
	}
	"""
	
	# Set the shader to the material
	hover_material.shader = hover_shader
	
	# Set initial shader parameters
	hover_material.set_shader_parameter("pulse_value", 0.0)
	hover_material.set_shader_parameter("outline_color", Color(1.0, 0.8, 0.0, 1.0))  # Golden outline
	hover_material.set_shader_parameter("outline_width", 6.0)  # Width of the outline

func _process(delta):
	# Update pulse animation if hovered
	if is_hovered and hover_material:
		pulse_time += delta * pulse_speed
		if pulse_time > 1.0:
			pulse_time -= 1.0
		hover_material.set_shader_parameter("pulse_value", pulse_time)
		
		# No need for debugging print in production
		# print(is_hovered)

func start():
	is_hovered = true
	material = hover_material
	pulse_time = 0.0  # Reset pulse timer

func stop():
	is_hovered = false
	material = normal_material

func _on_coffin_data_updated():
	update_sprite()

func update_sprite():
	if coffin_data:
		var people_count = coffin_data.people.size()
		
		# Clamp people count to match available sprites
		var sprite_index = min(people_count, coffin_sprites.size())
		
		# If we don't have a sprite for this many people, use the highest one
		if not coffin_sprites.has(sprite_index) or sprite_index < 1:
			sprite_index = coffin_sprites.size()
			
		# Update the sprite texture
		texture = coffin_sprites[sprite_index]
		
		# Re-expand the sprite region whenever texture changes
		expand_sprite_region()

func find_coffin_data():
	# Look for a CoffinData node starting from the scene root
	var current = self
	var max_depth = 5  # Limit search depth to avoid infinite loops
	var depth = 0
	
	while current and depth < max_depth:
		# Check if the current node has the get_full_name method
		if current.has_method("get_full_name"):
			return current
		
		# Check siblings of the current node
		var parent = current.get_parent()
		if parent:
			for child in parent.get_children():
				if child != current and child.has_method("get_full_name"):
					return child
		
		# Move up to the parent
		current = parent
		depth += 1
	
	# Look through the entire coffin scene
	var coffin = find_coffin_root()
	if coffin:
		for child in coffin.get_children():
			if child.has_method("get_full_name"):
				return child
	
	# Not found
	return null

func find_coffin_root():
	# Find the coffin node which is likely the grandparent of this sprite
	var current = self
	var max_depth = 3  # Limit search depth
	var depth = 0
	
	while current and depth < max_depth:
		var parent = current.get_parent()
		if not parent:
			break
			
		# If parent is the root node, assume current is the coffin
		if parent == get_tree().root:
			return current
			
		current = parent
		depth += 1
	
	return current

# Public method that can be called from outside to force a sprite update
func force_update():
	update_sprite() 

# Public method that can be called from outside to set hover state
func set_hover(hovered):
	print("set_hover: ", hovered)
	if hovered != is_hovered:
		if hovered:
			start()
		else:
			stop()

# Add this new function to expand the sprite region
func expand_sprite_region():
	# Get the current texture
	var original_texture = texture
	var tex_size = original_texture.get_size()
	
	# Define padding for the outline
	var padding = 16  # Pixels of padding on each side for the outline
	
	# Create a new larger transparent texture
	var expanded_size = Vector2(tex_size.x + padding*2, tex_size.y + padding*2)
	var expanded_image = Image.create(int(expanded_size.x), int(expanded_size.y), false, Image.FORMAT_RGBA8)
	
	# Make the entire image transparent
	expanded_image.fill(Color(0, 0, 0, 0))
	
	# Get the original image data
	var original_image = original_texture.get_image()
	
	# Blit the original image onto the center of the expanded image
	expanded_image.blit_rect(original_image, Rect2(0, 0, tex_size.x, tex_size.y), Vector2(padding, padding))
	
	# Create a new texture from the expanded image
	var expanded_texture = ImageTexture.create_from_image(expanded_image)
	
	# Set the new texture
	texture = expanded_texture
	
	# Reset region settings since we're using a new larger texture
	region_enabled = false
	centered = true
