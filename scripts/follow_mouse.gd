extends PointLight2D

var camera_target = null
@onready var bury_focus = $"/root/TilemapTest/bury_focus"
@onready var rules_focus = $"/root/TilemapTest/rules_focus"

enum Target {
	CURSOR,
	BURY_FOCUS,
	RULES_FOCUS
}

func _ready():
	set_camera_target(self.Target.CURSOR)

func set_camera_target(target: Target):
	## Call this from other scripts using CameraTarget.set_camera_target(CameraTarget.Target.CURSOR)
	## to change what the camera follows. Valid targets are:
	## - Target.CURSOR: Follow the mouse cursor
	## - Target.BURY_FOCUS: Focus on the burial area
	## - Target.RULES_FOCUS: Focus on the rules area
	match target:
		self.Target.CURSOR:
			camera_target = Cursor
		self.Target.BURY_FOCUS:
			camera_target = bury_focus
		self.Target.RULES_FOCUS:
			camera_target = rules_focus
		_:
			camera_target = Cursor

func _process(delta: float) -> void:
	global_position = camera_target.global_position
