extends Node2D

@export var start_tiles : Array[Vector2i]
@export var probe_radius : int = 0
@export var max_instability : int = 10

var current_layer = 0
var instability = 0

@onready var layers = $Layers
@onready var camera = $Camera2D
@onready var instability_progress = $HUD/Margin/Instability

func _ready() -> void:
	instability_progress.max_value = max_instability
	
	camera.connect("target_layer", target_layer)
	var start_layer : Node2D = layers.find_child("Layer0")
	for tile in start_tiles:
		start_layer.reveal_node(tile)
	
	var i = 0
	for layer in layers.get_children():
		if i == 0:
			for tile in start_tiles:
				start_layer.reveal_node(tile)
		else:
			layer.hide()

		layer.z_index -= i
		i += 1
		layer.connect("drop_probe", drop_probe.bind(i))
		layer.connect("destroyed", destroy_tile)
		layer.get_radius = get_radius

func drop_probe(coords, index):
	var layer = get_layer(index)
	if layer:
		var hit_tile = layer.trigger_node(coords)
		change_layer(layer, index)

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

func destroy_tile():
	instability += 1
	instability_progress.value = instability
	camera.shake()
	var instability_percent = float(instability) / float(max_instability)
	if instability_percent > 0.7:
		instability_progress.modulate = Color("#9a6278")
	elif instability_percent > 0.4:
		instability_progress.modulate = Color("#c7786f")
	if instability > max_instability:
		print("oh no")
