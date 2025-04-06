extends Node2D

@export var probe_radius : int = 2
@export var max_stability : int = 10
@export var levels : Array[PackedScene]
@export var start_level = 0

var current_layer = 0
var stability = max_stability
var score = 0
var level = 0
var layers : Node2D
var total_score = 0
var start_camera : Vector2
var level_end_descriptions = { # TODO make these not suck
	"escape": "Yay you did it",
	"exit_destroyed": "You fucked up",
	"instability": "Everything is awful",
}

@onready var camera = $Camera2D
@onready var stability_progress = $HUD/Margin/StabilityContainer/Stability
@onready var stability_label = $HUD/Margin/StabilityContainer/Stability/Label
@onready var score_display = $HUD/Margin/Score
@onready var hud_container = $HUD/Margin
@onready var action_blocker = $HUD/ModalContainer/Blocker
@onready var level_end_modal = $HUD/ModalContainer/LevelEnd
@onready var level_end_title = $HUD/ModalContainer/LevelEnd/Margin/Content/Title
@onready var level_end_text = $HUD/ModalContainer/LevelEnd/Margin/Content/Body/Text

func _ready() -> void:
	stability_progress.max_value = max_stability
	stability_label.text = str(stability) + "/" + str(max_stability)
	level_end_modal.hide()
	
	start_camera = camera.position
	camera.connect("target_layer", target_layer)
	
	level = start_level
	init_level()

func init_level():
	camera.position = start_camera
	camera.force_update_scroll()
	
	if layers:
		remove_child(layers)
		layers.queue_free()

	score = 0
	stability = max_stability
	current_layer = 0
	
	score_display.text = str(score)
	stability_progress.value = stability
	stability_progress.self_modulate = Color("#cfa98a")
	stability_label.text = str(stability) + "/" + str(max_stability)

	layers = levels[level].instantiate()
	add_child(layers)
	
	var start_layer : Node2D = layers.get_child(0)

	var i = 0
	for layer in layers.get_children():
		if i > 0:
			layer.hide()
		layer.z_index -= i
		i += 1

		layer.connect("drop_probe", drop_probe.bind(i))
		layer.connect("destroyed", destroy_tile)
		layer.connect("escaped", escape_level)
		layer.connect("got_artifact", update_score.bind(1))
		layer.connect("lost_artifact", update_score.bind(-1))
		layer.connect("escape_destroyed", escape_destroyed)
		layer.get_radius = get_radius

func drop_probe(coords, grid_size, index):
	var layer = get_layer(index)
	coords = layer.apply_grid_offset(coords, grid_size)
	if layer:
		var hit_tile = layer.trigger_node(coords)
		change_layer(layer, index)
		if hit_tile is not GapTile:
			await get_tree().create_timer(0.165).timeout
			camera.shake(0.3)

func get_radius():
	return probe_radius

func get_layer(index):
	if index >= layers.get_child_count():
		return
	return layers.get_child(index)
	
func change_layer(layer, index):
	camera.focus_layer(layer)
	current_layer = index
	
	var other_i = 0
	for other_layer in layers.get_children():
		if other_layer == layer:
			continue
		if other_i < index:
			other_layer.hide_layer()
		else:
			other_layer.show_layer()
			other_layer.self_modulate = Color("#60556e")
		other_layer.process_mode = Node.PROCESS_MODE_DISABLED
		other_i += 1
	layer.show_layer()
	layer.process_mode = Node.PROCESS_MODE_INHERIT
	
func target_layer(offset):
	var index = current_layer + offset
	var layer = get_layer(index)
	if layer and layer.visible:
		change_layer(layer, index)

func destroy_tile(nodes_remaining):
	action_blocker.mouse_filter = 0
	stability -= 1
	stability_progress.value = stability
	stability_label.text = str(stability) + "/" + str(max_stability)

	camera.shake()
	
	if nodes_remaining <= 0:
		action_blocker.mouse_filter = 1

	var stability_percent = float(stability) / float(max_stability)
	if stability_percent < 0.3:
		stability_progress.self_modulate = Color("#9a6278")
	elif stability_percent < 0.6:
		stability_progress.self_modulate = Color("#c7786f")

	if stability <= 0:
		fail_level("instability")

func escape_destroyed():
	fail_level("exit_destroyed", 0.5)

func fail_level(fail_type, delay=1):
	action_blocker.mouse_filter = 0
	await get_tree().create_timer(delay).timeout
	show_level_end(fail_type, false)

func escape_level():
	action_blocker.mouse_filter = 0
	await get_tree().create_timer(1).timeout
	action_blocker.mouse_filter = 1
	show_level_end("escape", true)

func show_level_end(end_type, win=false):
	if win:
		total_score += score
		if len(levels) > level + 1:
			level += 1
		else:
			print("todo")
	else:
		level_end_title.text = "You Died"

	level_end_text.text = level_end_descriptions[end_type]
		
	get_tree().paused = true
	level_end_modal.show()

func _on_level_end_action_pressed() -> void:
	level_end_modal.hide()
	get_tree().paused = false
	action_blocker.mouse_filter = 1
	init_level()

func update_score(value):
	score += value
	score_display.text = str(score)
