extends PointLight2D

var camera_target = null
@onready var bury_focus = $"/root/TilemapTest/bury_focus"
@onready var rules_focus = $"/root/TilemapTest/rules_focus"
@onready var menu_focus = $"/root/TilemapTest/menu_focus"
@onready var drill: Node2D = $"/root/TilemapTest/Drill"
@onready var camera: Camera2D = get_node('Camera2D')

@export var limit_top = -800
@export var limit_top_max = -1000000000
@export var limit_bottom_max = 3300

var current_target: Target

enum Target {
	CURSOR,
	BURY_FOCUS,
	RULES_FOCUS,
	MENU_FOCUS
}

func _ready():
	camera.position_smoothing_enabled = false
	set_camera_target(self.Target.CURSOR)
	set_camera_limits(0, 1620, limit_top_max, limit_bottom_max)

func enable_margins():
	camera.drag_top_margin = 0.7
	camera.drag_bottom_margin = 0.7

func disable_margins():
	camera.drag_top_margin = 0.0
	camera.drag_bottom_margin = 0.0

# Function to set camera limits
func set_camera_limits(left: float, right: float, top: float, bottom: float):
	# Enable limits
	camera.limit_left = left
	camera.limit_right = right
	camera.limit_top = top
	camera.limit_bottom = bottom

func enable_top_limit():
	camera.limit_top = limit_top

func disable_top_limit():
	camera.limit_top = limit_top_max
	camera.limit_bottom = limit_bottom_max



func set_camera_target(target: Target):
	print("changement de camera target", target)
	## Call this from other scripts using CameraTarget.set_camera_target(CameraTarget.Target.CURSOR)
	## to change what the camera follows. Valid targets are:
	## - Target.CURSOR: Follow the mouse cursor
	## - Target.BURY_FOCUS: Focus on the burial area
	## - Target.RULES_FOCUS: Focus on the rules area
	## - Target.MENU_FOCUS: Focus on the menu area
	current_target = target
	match target:
		self.Target.CURSOR:
			enable_margins()
			enable_top_limit()
			camera_target = Cursor
		self.Target.BURY_FOCUS:
			disable_margins()
			disable_top_limit()
			camera_target = bury_focus
		self.Target.RULES_FOCUS:
			camera.position_smoothing_enabled = true
			disable_margins()
			disable_top_limit()
			camera_target = rules_focus
		self.Target.MENU_FOCUS:
			disable_margins()
			disable_top_limit()
			camera_target = menu_focus
		_:
			enable_margins()
			disable_top_limit()
			camera_target = Cursor

func _process(delta: float) -> void:
	global_position = camera_target.global_position
	if current_target == self.Target.CURSOR:
		if Phase.current_phase == "drill":
			var half_screen_height: int = int(get_viewport().get_visible_rect().size.y * 0.90)
			camera.limit_top = lerp(camera.limit_top, max(limit_top, int(drill.global_position.y) - half_screen_height), 0.1)
			camera.limit_bottom = lerp(camera.limit_bottom, min(limit_bottom_max, int(drill.global_position.y) + half_screen_height), 0.1)
		else:
			camera.limit_top = limit_top
			camera.limit_bottom = limit_bottom_max
