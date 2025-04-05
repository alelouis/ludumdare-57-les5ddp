extends Area2D

@export var ground: Ground
@export var fuel: ColorRect
@export var first_destroyable_row = 10

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_rotation = 0
	if ground:
		erase_tiles_in_area(ground.tile_map_layer)

func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer:
		print("tilemap", body)

func _on_area_entered(area: Area2D) -> void:
	print(area)
	
func remove_tile(tilemap_layer: TileMapLayer, cell: Vector2i):
	tilemap_layer.erase_cell(cell)

func erase_tiles_in_area(tilemap_layer: TileMapLayer):
	# Get the global bounding box (AABB) of the collision shape
	var local_aabb: Rect2 = collision_shape_2d.shape.get_rect()
	var cshape_global_transform: Transform2D = collision_shape_2d.global_transform
	var transformed_top_left = cshape_global_transform * local_aabb.position
	var transformed_bottom_right = cshape_global_transform * (local_aabb.position + local_aabb.size)
	var global_aabb = Rect2(
		transformed_top_left,
		transformed_bottom_right - transformed_top_left
	)

	var top_left_global = global_aabb.position
	var bottom_right_global = global_aabb.position + global_aabb.size

	var top_left_local = tilemap_layer.to_local(top_left_global)
	var bottom_right_local = tilemap_layer.to_local(bottom_right_global)

	var start_cell: Vector2i = tilemap_layer.local_to_map(top_left_local)
	var end_cell: Vector2i = tilemap_layer.local_to_map(bottom_right_local)

	# Ensure correct iteration order if transform flips coordinates
	var min_cell_x = min(start_cell.x, end_cell.x)
	var max_cell_x = max(start_cell.x, end_cell.x)
	var min_cell_y = min(start_cell.y, end_cell.y)
	var max_cell_y = max(start_cell.y, end_cell.y)

	# 4. Get the physics space state for point collision checks
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	if not space_state:
		printerr("erase_tiles_in_area: Could not get direct space state.")
		return

	# 5. Prepare the point query parameters
	#    We want to check if the center of each tile cell collides with our specific Area2D.
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false # We only care about the Area2D itself
	# Check against the layer the Area2D is on
	query.collision_mask = collision_layer

	# 6. Iterate through every cell within the calculated map range
	for y in range(min_cell_y, max_cell_y + 1):
		for x in range(min_cell_x, max_cell_x + 1):
			if y < first_destroyable_row:
				continue
				
			var current_cell = Vector2i(x, y)

			# Optimization: Skip if the cell is already empty
			if tilemap_layer.get_cell_source_id(current_cell) == -1:
				continue

			# 7. Find the global position of the center of the current cell
			var cell_center_local = tilemap_layer.map_to_local(current_cell)
			var cell_center_global = tilemap_layer.to_global(cell_center_local) + 0.5 * tilemap_layer.tile_set.tile_size

			query.position = cell_center_global
			var results: Array = space_state.intersect_point(query, 1) # Query max 1 result for efficiency

			var point_is_inside_area = not results.is_empty() and results[0]["collider"] == self

			if point_is_inside_area:
				remove_tile(tilemap_layer, current_cell)
				fuel.drain(1)
