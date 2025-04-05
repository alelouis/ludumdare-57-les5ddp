extends Area2D
@export var terrain_type: String = "mud" 


func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	body.change_terrain_force_multiplier(terrain_type)
		
func _on_body_exited(body: Node2D):
	body.change_terrain_force_multiplier("default")
