extends Node2D

@onready var coffin_generator = $CoffinSpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().create_timer(2.0).timeout.connect(func(): _pickable_coffins())

func _pickable_coffins():
	coffin_generator.set_pickable_coffins(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
