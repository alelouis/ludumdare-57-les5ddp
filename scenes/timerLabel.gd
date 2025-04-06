extends Label

@export var start_time: float = 61.0  # start from 60 seconds
@export var count_down: bool = true   # set to false to count up
@onready var end_button := $"../Button"  # adjust path if needed
@onready var text_label = $"../RichTextLabel"
@onready var text_label_shadow = $"../RichTextLabelShadow"
@onready var level_label = $"../LevelLabel"

var time_left: float
var end_triggered = false 
var current_level = 1

func _ready():
	level_label.hide()
	end_button.hide()
	text_label.hide()
	text_label_shadow.hide()
	time_left = start_time
	end_button.pressed.connect(_on_end_pressed)
	Phase.phase_changed.connect(_on_phase_changed)
	update_text()
	self.hide()

func _process(delta: float) -> void:
	if !end_triggered:
		if count_down:
			time_left = max(0.0, time_left - delta)
		else:
			time_left += delta
		update_text()
	if count_down and time_left <= 0.0 and !end_triggered:
		on_timer_finished()

func update_text():
	text = format_time(time_left)

func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

func on_timer_finished():
	# Called once when timer hits 0
	end_triggered = true;
	end_button.hide();
	Phase.next_level()

func _on_end_pressed():
	if Phase.current_phase == "drill":
		Phase.next_phase()
	else:
		time_left = 0.0
		update_text()
		on_timer_finished()
	
func _on_phase_changed():
	if Phase.current_phase == 'drill':
		if !level_label.visible:
			level_label.show()
		end_button.text = "End drilling"
		self.show()
		time_left = 60.0
		end_triggered = false
		end_button.show();
		text_label.show_text("Drillin' Time !!!")
		text_label.lifetime = 5.0
		text_label_shadow.show_text("Drillin' Time !!!")
		text_label_shadow.lifetime = 5.0

	if Phase.current_phase == 'coffin':
		end_button.text = "End of the night"
		text_label.show_text("Coffin' Time !!!")
		text_label_shadow.show_text("Coffin' Time !!!")
	if Phase.current_phase == 'cinematic':
		level_label.text = "Days without incident: %s " % (Phase.current_level - 1) 
		end_button.hide();
		self.hide()
		text_label.show_text("The Night is Over !!!")
		text_label.lifetime = 1.0
		text_label_shadow.show_text("The Night is Over !!!")
		text_label_shadow.lifetime = 1.0
