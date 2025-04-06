extends Node2D

signal triggered_node
signal drop_probe
signal destroyed

const tile_height = 8
const tile_width = 16

var gap_tile : PackedScene
var tile_grid = []
var get_radius : Callable = func(): return 0

@onready var tile_container = $TileContainer

func _ready() -> void:
	var children = tile_container.get_children()
	tile_grid = tiles_to_grid(children)
	gap_tile = preload("res://scenes/gap_tile.tscn")

func reveal_node(coords):
	if coords.x < 0 or coords.y < 0 or coords.x >= len(tile_grid) or coords.y >= len(tile_grid[0]):
		return
	tile_grid[coords.x][coords.y].reveal()

func trigger_node(coords):
	show()
	var tile = tile_grid[coords.x][coords.y]
	tile.activate()
	return tile

func destroy_node(coords):
	var old_node = tile_grid[coords.x][coords.y]
	if old_node.state == 0:
		old_node.reveal()
		await get_tree().create_timer(0.25).timeout
	
	if old_node is GapTile:
		return
	if old_node is UnstableTile:
		if old_node.state != 2:
			old_node.activate()
			return
	var old_position = old_node.position
	tile_container.remove_child(old_node)
	old_node.queue_free()
	
	var new_node = gap_tile.instantiate()
	new_node.connect("activated", trigger_effect.bind(Vector2i(coords.x, coords.y)))
	tile_container.add_child(new_node)
	new_node.position = old_position
	tile_grid[coords.x][coords.y] = new_node
	new_node.create_gap()
	new_node.call_deferred("set_state", 1)
	
	emit_signal("destroyed")

func tiles_to_grid(tiles):
	var positions = {}
	var grid_size = sqrt(len(tiles))
	assert(not fmod(grid_size, 1))
	
	for tile in tiles:
		var x = tile.position.x
		var y = tile.position.y
		var col = (x / tile_width) - (y / tile_height) + (grid_size / 2) - 0.5
		var row = (x / tile_width) + (y / tile_height) + (grid_size / 2) - 0.5

		positions[Vector2(row, col)] = tile

	var grid = []
	for r in range(grid_size):
		var row_list = []
		for c in range(grid_size):
			var tile = positions.get(Vector2(r, c), null)
			row_list.append(tile)
			tile.connect("activated", trigger_effect.bind(Vector2i(r, c)))
		grid.append(row_list)

	return grid

func hide_layer():
	tile_container.get_material().set_shader_parameter("is_active", true)
	self_modulate = Color.WHITE
	self_modulate.a = 0.5

func show_layer():
	tile_container.get_material().set_shader_parameter("is_active", false)
	self_modulate = Color.WHITE

func trigger_effect(effect, coords):
	call(effect, coords)

func get_neighbors(coords, radius):
	var neighbors = []
	var offsets = [
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(0, -1),
		Vector2i(0, 1),
	]
	if radius % 2:
		offsets += [
			Vector2i(1, 1),
			Vector2i(-1, 1),
			Vector2i(-1, -1),
			Vector2i(1, -1),
		]
		radius -= 1
	for offset in offsets:
		var neighbor_row = coords.x + offset.x
		var neighbor_col = coords.y + offset.y
		if neighbor_row >= 0 and neighbor_row < len(tile_grid) and neighbor_col >= 0 and neighbor_col < len(tile_grid[0]):
			neighbors.append(Vector2i(neighbor_row, neighbor_col))
	
	var current_neighbors = neighbors.duplicate()
	if radius > 0:
		for neighbor in current_neighbors:
			neighbors += get_neighbors(neighbor, radius - 1)
	return neighbors
	
func reveal_neighbors(coords):
	for neighbor in get_neighbors(coords, get_radius.call()):
		reveal_node(neighbor)
	
func destroy(coords):
	destroy_node(coords)
	for neighbor in get_neighbors(coords, 0):
		destroy_node(neighbor)

func drop(coords):
	emit_signal("drop_probe", coords)
