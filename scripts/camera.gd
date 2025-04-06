extends Camera2D

signal target_layer

@export var drag_delay = 1
@export var drag_bounds_y = 75
@export var drag_bounds_x = 80
@export var shake_time = 0.25
@export var shake_factor = 1.5

var shake_countdown = 0
var shake_start = Vector2.ZERO
var drag_cooldown = 0
var shake_intensity = shake_factor

func _process(delta: float) -> void:
	if drag_cooldown > 0:
		drag_cooldown -= delta
		
	if shake_countdown <= 0:
		return

	shake_countdown -= delta
	if shake_countdown <= 0:
		offset = Vector2()
	else:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)

func _input(event):
	if event is InputEventMouseMotion:
		var screen_center = get_viewport_rect().size / 2
		var center_offset = event.position - screen_center
		if drag_cooldown > 0:
			return
		if abs(center_offset.x) > drag_bounds_x:
			return
		if center_offset.y < -drag_bounds_y:
			emit_signal("target_layer", -1)
		elif center_offset.y > drag_bounds_y:
			emit_signal("target_layer", 1)

func focus_layer(layer):
	position.y = layer.position.y
	drag_cooldown = drag_delay

func shake(intensity=shake_factor):
	shake_countdown = shake_time
	shake_intensity = intensity
