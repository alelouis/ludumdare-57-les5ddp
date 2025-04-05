extends Node2D

@onready var cursor_sprite = load("res://assets/sprites/cursor.png")
@onready var hand_sprite = load("res://assets/sprites/main.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_cursor_sprite("hand")

func set_cursor_sprite(string):
	var sprite = null
	var offset = Vector2(0, 0)
	if string == "hand":
		sprite = hand_sprite
		scale = Vector2(-2, 2)
		rotation = 0
		offset = Vector2(0, -15)
		
	if string == "cursor":
		sprite = cursor_sprite
		scale = Vector2(1, 1)
		offset = Vector2(-50, -15)

	# Set the Sprite2D child's texture
	var sprite2d = $Sprite2D
	if sprite2d and sprite:
		sprite2d.texture = sprite
		sprite2d.offset = offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()
