extends Area2D

# Export variables to control rectangle bounds from the inspector
@export var left_bound: float = -100.0
@export var right_bound: float = 100.0
@export var top_bound: float = -100.0
@export var bottom_bound: float = 100.0

# Scene to spawn inside the area
@export var spawn_scene: PackedScene
@export var auto_spawn_on_ready: bool = true
@export var spawn_count: int = 1

# Spawn timing and physics settings
@export var min_spawn_delay: float = 0.0  # Minimum delay between spawns in seconds
@export var max_spawn_delay: float = 0.2  # Maximum delay between spawns in seconds
@export var min_angular_velocity: float = -1.0  # Minimum initial angular velocity
@export var max_angular_velocity: float = 1.0   # Maximum initial angular velocity

# Collision tracking
var tracked_coffins = []
var collision_pairs = {}
var last_collision_time = 0
var collision_cooldown = 0.1  # Time in seconds between collision reports

# Reference to the CollisionShape2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	# Update collision shape based on bounds
	update_spawn_count()
	update_collision_shape()
	Phase.instance.phase_changed.connect(_on_phase_changed)

# Set up collision detection for all coffins
func _setup_collision_detection():
	# Find all RigidBody2D nodes (coffins) in children
	tracked_coffins = []
	for child in get_children():
		var rigidbody = find_rigidbody_child(child)
		if rigidbody:
			# Enable contact monitoring for the rigidbody
			rigidbody.contact_monitor = true
			rigidbody.max_contacts_reported = 10
			rigidbody.body_entered.connect(func(body): _on_coffin_collision(rigidbody, body))
			tracked_coffins.append(rigidbody)

# Called when one coffin collides with another
func _on_coffin_collision(coffin1, coffin2):
	# Check if enough time has passed since last collision report
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_collision_time < collision_cooldown:
		return
	
	# Create a unique ID for this collision pair
	var collision_id
	if coffin1.get_instance_id() < coffin2.get_instance_id():
		collision_id = str(coffin1.get_instance_id()) + "_" + str(coffin2.get_instance_id())
	else:
		collision_id = str(coffin2.get_instance_id()) + "_" + str(coffin1.get_instance_id())
	
	# Check if we already reported this collision recently
	if collision_id in collision_pairs:
		if current_time - collision_pairs[collision_id] < collision_cooldown:
			return
	
	# Update collision time
	last_collision_time = current_time
	collision_pairs[collision_id] = current_time
	
	# Get coffin data for both coffins
	var coffin_data1 = find_coffin_data(coffin1.get_parent())
	var coffin_data2 = find_coffin_data(coffin2.get_parent())
	
	if coffin_data1 and coffin_data2:
		# Get names
		var name1 = coffin_data1.get_full_name()
		var name2 = coffin_data2.get_full_name()
		
		# Check if they share the same last name
		var can_merge = false
		
		# Check if any person in coffin1 shares a last name with any person in coffin2
		for person1 in coffin_data1.people:
			for person2 in coffin_data2.people:
				if person1.last_name == person2.last_name and person1.last_name != "":
					can_merge = true
					break
			if can_merge:
				break
		
		if can_merge:
			# Hide any active tooltips
			if "coffin_interaction.gd" in ResourceLoader.get_recognized_extensions_for_type("Script"):
				var script = load("res://scripts/coffin_interaction.gd")
				if script and script.has_method("hide_all_tooltips"):
					script.hide_all_tooltips()
			# Calculate the average position and rotation
			var avg_position = (coffin1.global_position + coffin2.global_position) / 2
			var avg_rotation = coffin1.rotation
			
			# Create a new merged coffin
			var merged_coffin = spawn_scene.instantiate()
			merged_coffin.global_position = avg_position
			
			# Find the RigidBody2D 
			var rigidbody = find_rigidbody_child(merged_coffin)
			if rigidbody:
				# Use average rotation instead of random
				if rigidbody.has_method("get") and rigidbody.get("rotation_start") != null:
					rigidbody.rotation_start = avg_rotation
				# Add an initial angular velocity
				var merge_spin = randf_range(-4.0, 4.0)
				rigidbody.angular_velocity = merge_spin
				
				# Add upward impulse for effect
				rigidbody.apply_central_impulse(Vector2(0, -50))
				
				# Set up collision detection
				rigidbody.contact_monitor = true
				rigidbody.max_contacts_reported = 1000
				rigidbody.body_entered.connect(func(body): _on_coffin_collision(rigidbody, body))
				tracked_coffins.append(rigidbody)
			
			# Find the coffin data
			var merged_data = find_coffin_data(merged_coffin)
			if merged_data:
				# Transfer all people from both coffins to the new one
				for person in coffin_data1.people:
					merged_data.add_person(
						person.first_name,
						person.last_name,
						person.birth_date,
						person.death_date
					)
				
				for person in coffin_data2.people:
					merged_data.add_person(
						person.first_name,
						person.last_name,
						person.birth_date,
						person.death_date
					)
				
				# Explicitly call data_updated to ensure the sprite updates
				merged_data.emit_signal("data_updated")
				
				# Find and update the sprite using the new coffin_display component
				update_coffin_sprite(merged_coffin)
				
			# Add to the scene
			add_child(merged_coffin)
			merged_coffin.get_node("CPUParticles2D").emitting = true
			
			# Delete the original coffins
			remove_coffin(coffin1)
			remove_coffin(coffin2)
		

# Remove a coffin and update tracking
func remove_coffin(coffin_body):
	# Remove from tracked_coffins array
	if tracked_coffins.has(coffin_body):
		tracked_coffins.erase(coffin_body)
	
	# Get the parent coffin scene and queue it for deletion
	var coffin_scene = coffin_body.get_parent()
	if coffin_scene:
		coffin_scene.queue_free()

# Create a new coffin at the specified position with merged names
func create_merged_coffin(position, first_name1, first_name2, last_name):
	if not spawn_scene:
		push_error("No scene assigned to spawn_scene")
		return null
	
	# Create a new coffin instance
	var instance = spawn_scene.instantiate()
	instance.global_position = position
	
	# Find the RigidBody2D and set rotation
	var rigidbody = find_rigidbody_child(instance)
	if rigidbody:
		# Random rotation
		var random_rotation = randf_range(0, 2 * PI)
		if rigidbody.has_method("get") and rigidbody.get("rotation_start") != null:
			rigidbody.rotation_start = random_rotation
		
		# Add an initial angular velocity - stronger than regular coffins
		var merge_spin = randf_range(-4.0, 4.0)  # Random direction
		rigidbody.angular_velocity = merge_spin
		
		# Also add a slight upward impulse for a more dramatic effect
		rigidbody.apply_central_impulse(Vector2(0, -50))
		
		# Set up collision detection
		if tracked_coffins.size() > 0:
			rigidbody.contact_monitor = true
			rigidbody.max_contacts_reported = 10
			rigidbody.body_entered.connect(func(body): _on_coffin_collision(rigidbody, body))
			tracked_coffins.append(rigidbody)
	
	# Find the coffin data and set the merged name
	var coffin_data = find_coffin_data(instance)
	if coffin_data:
		# Combine the first names with a hyphen and use the shared last name
		coffin_data.first_name = first_name1 + ", " + first_name2
		coffin_data.last_name = last_name
		
		# Set dates to be a range from the earliest to latest
		var birth_year = str(randi_range(1900, 1950))
		var death_year = str(randi_range(2000, 2023))
		coffin_data.birth_date = birth_year
		coffin_data.death_date = death_year
		
	# Add to the scene
	add_child(instance)
	
	return instance

# Helper function to find coffin data node
func find_coffin_data(node):
	# Check if this node has the get_full_name method
	if node and node.has_method("get_full_name"):
		return node
	
	# If not, check its children
	if node:
		for child in node.get_children():
			if child.has_method("get_full_name"):
				return child
	
	return null

# Update the collision shape to match the exported bounds
func update_collision_shape():
	if collision_shape and collision_shape.shape is RectangleShape2D:
		# Calculate width and height from bounds
		var width = right_bound - left_bound
		var height = bottom_bound - top_bound
		
		# Update the rectangle shape
		collision_shape.shape.size = Vector2(width, height)
		
		# Center the collision shape
		collision_shape.position = Vector2(
			left_bound + width / 2,
			top_bound + height / 2
		)

# Spawn a single scene at a random position inside the area
func spawn_scene_at_random_position():

	if not spawn_scene:
		push_error("No scene assigned to spawn_scene")
		return null
		
	# Create instance of the scene
	var instance = spawn_scene.instantiate()
	
	# Calculate random position within bounds
	var x = randf_range(left_bound, right_bound)
	var y = randf_range(top_bound, bottom_bound)
	
	# Set position
	instance.global_position = global_position + Vector2(x, y)
	
	# Find RigidBody2D child and randomize its rotation_start
	var rigidbody = find_rigidbody_child(instance)
	if rigidbody and rigidbody.has_method("get") and rigidbody.get("rotation_start") != null:
		# Random angle between 0 and 2*PI (full circle)
		var random_rotation = randf_range(0, 2 * PI)
		rigidbody.rotation_start = random_rotation
		
		# Give it a random angular velocity
		rigidbody.angular_velocity = randf_range(min_angular_velocity, max_angular_velocity)
	
	# Add to the tree
	add_child(instance)
	
	# If we're tracking collisions, set up this new coffin
	if tracked_coffins.size() > 0 and rigidbody:
		rigidbody.contact_monitor = true
		rigidbody.max_contacts_reported = 10
		rigidbody.body_entered.connect(func(body): _on_coffin_collision(rigidbody, body))
		tracked_coffins.append(rigidbody)
	
	return instance

# Helper function to find the RigidBody2D child in the scene
func find_rigidbody_child(node):
	# If this node is a RigidBody2D, return it
	if node is RigidBody2D:
		return node
		
	# Search all children
	for child in node.get_children():
		var result = find_rigidbody_child(child)
		if result:
			return result
			
	# Not found
	return null

# Spawn multiple scenes with random delays between them
func spawn_scenes_with_delay(count: int):
	for i in range(count):
		var delay = randf_range(min_spawn_delay, max_spawn_delay)
		if i == 0:  # First spawn happens immediately
			spawn_scene_at_random_position()
		else:
			# Create a timer for delayed spawn
			var timer = get_tree().create_timer(delay)
			timer.timeout.connect(func():
				spawn_scene_at_random_position()
			)

# Legacy method that spawns all instances at once
# Kept for compatibility but we now prefer spawn_scenes_with_delay
func spawn_scenes(count: int):
	for i in range(count):
		spawn_scene_at_random_position()

# Call this method whenever you want to spawn a new scene
func spawn_new_scene():
	spawn_scene_at_random_position()
	
# Handle property changes in the editor
func _set(property, value):
	if property in ["left_bound", "right_bound", "top_bound", "bottom_bound"]:
		set(property, value)
		update_collision_shape()
		return true
	return false 

# Find and update the sprite display after merging people
func update_coffin_sprite(coffin):
	var sprite_display = find_sprite_display(coffin)
	if sprite_display and sprite_display.has_method("force_update"):
		sprite_display.force_update()

# Helper to find the Sprite2D with the coffin_display script
func find_sprite_display(coffin):
	# Find the rigidbody first
	var rigidbody = find_rigidbody_child(coffin)
	if not rigidbody:
		return null
		
	# Look for a Sprite2D in the rigidbody's children
	for child in rigidbody.get_children():
		if child is Sprite2D and child.has_method("force_update"):
			return child
			
	# Look one level deeper if needed
	for child in rigidbody.get_children():
		for grandchild in child.get_children():
			if grandchild is Sprite2D and grandchild.has_method("force_update"):
				return grandchild
				
	return null

# Calculate Fibonacci number for a given position in the sequence
func fibonacci(n: int) -> int:
	if n <= 0:
		return 0
	elif n == 1:
		return 1
	
	# Use iteration to compute Fibonacci number
	var a = 0
	var b = 1
	var result = 0
	
	for i in range(2, n + 1):
		result = a + b
		a = b
		b = result
	
	return result

func update_spawn_count():
	# Use Fibonacci sequence to determine spawn count based on current level
	# Add a base value to ensure we always have at least some coffins
	spawn_count = fibonacci(Phase.instance.current_level+2)
	

func _on_phase_changed(): 
	if Phase.instance.current_phase == 'drill':
		update_spawn_count()
		# Spawn scenes if auto-spawn is enabled
		if auto_spawn_on_ready and spawn_scene:
			spawn_scenes_with_delay(spawn_count)
		
		# Start tracking collisions after a short delay to let objects settle
		get_tree().create_timer(1.0).timeout.connect(func(): _setup_collision_detection())
