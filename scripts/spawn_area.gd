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
@export var min_spawn_delay: float = 0.1  # Minimum delay between spawns in seconds
@export var max_spawn_delay: float = 0.5  # Maximum delay between spawns in seconds
@export var min_angular_velocity: float = -1.0  # Minimum initial angular velocity
@export var max_angular_velocity: float = 1.0   # Maximum initial angular velocity

# Reference to the CollisionShape2D
@onready var collision_shape = $CollisionShape2D

func _ready():
    # Update collision shape based on bounds
    update_collision_shape()
    
    # Spawn scenes if auto-spawn is enabled
    if auto_spawn_on_ready and spawn_scene:
        spawn_scenes_with_delay(spawn_count)

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
        print("Set rigidbody rotation_start: ", random_rotation, " and angular_velocity: ", rigidbody.angular_velocity)
    else:
        print("Could not find rigidbody with rotation_start variable")
    
    # Add to the tree
    add_child(instance)
    
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
            print("Spawned scene 1 immediately")
        else:
            # Create a timer for delayed spawn
            var timer = get_tree().create_timer(delay)
            timer.timeout.connect(func(): 
                print("Spawned scene ", i+1, " after ", delay, " seconds")
                spawn_scene_at_random_position()
            )

# Legacy method that spawns all instances at once
# Kept for compatibility but we now prefer spawn_scenes_with_delay
func spawn_scenes(count: int):
    for i in range(count):
        print('spawning scene: ', i)
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