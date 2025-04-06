extends Node2D

@onready var cursor_sprite = load("res://assets/sprites/cursor.png")
@onready var hand_sprite = load("res://assets/sprites/main.png")
@onready var drill_sprite = load("res://assets/sprites/cursor_drill.png")
@onready var drill: Node2D = $"/root/TilemapTest/Drill"

var current_cursor: String

# Called when the node enters the scene tree for the first time.
func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_cursor_sprite("hand")
	Phase.phase_changed.connect(on_phase_changed)
	
func on_phase_changed():
	match Phase.current_phase:
		"drill":
			set_cursor_sprite("drill")
		"coffin":
			set_cursor_sprite("hand")

func set_cursor_sprite(string):
	current_cursor = string
	var sprite = null
	var offset = Vector2(0, 0)
	if string == "hand":
		rotation = 0
		sprite = hand_sprite
		scale = Vector2(-2, 2)
		offset = Vector2(0, -15)
		
	if string == "cursor":
		rotation = 0
		sprite = cursor_sprite
		scale = Vector2(1, 1)
		offset = Vector2(-50, -15)
		
	if string == "drill":
		sprite = drill_sprite
		scale = Vector2(1, 1)
		offset = Vector2(0, 162/2.0)

	# Set the Sprite2D child's texture
	var sprite2d = $Sprite2D
	if sprite2d and sprite:
		sprite2d.texture = sprite
		sprite2d.offset = offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_cursor == "drill":
		# Calculate and set the hand rotation to face the mouse
		var direction = (get_global_mouse_position() - drill.global_position).normalized()
		var angle = atan2(direction.y, direction.x)
		# Adjust the angle by 90 degrees (PI/2) if the hand needs to point along the direction
		rotation = angle - PI/2
		pass
	global_position = get_global_mouse_position()
	
