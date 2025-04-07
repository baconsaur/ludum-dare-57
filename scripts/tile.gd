class_name BaseTile
extends Sprite2D

signal activated
signal scan

enum states {HIDDEN, REVEALED, ACTIVATED}

@export var frame_index_map : Dictionary[states, int] = {
	states.HIDDEN: 0,
	states.REVEALED: 0,
	states.ACTIVATED: 0,
}
@export var start_revealed = false

var state = states.HIDDEN
var activate_particles : CPUParticles2D
var scan_result : Node2D
var can_scan = false
var temp_scan_tween : Tween

@onready var fog_sprite = $Fog
@onready var cursor = $Cursor

func _ready() -> void:
	activate_particles = find_child("ActivateParticles")
	scan_result = find_child("ScanResult")
	if scan_result:
		scan_result.hide()
	
	if start_revealed:
		set_state(states.REVEALED)
	else:
		fog_sprite.show()
		set_state(states.HIDDEN)

func _process(delta: float) -> void:
	if state != states.REVEALED:
		return
	check_cursor()

func check_cursor():
	var rect = cursor.get_rect()
	if rect.has_point(get_local_mouse_position()):
		cursor.show()
	else:
		cursor.hide()

func reveal():
	if state != states.HIDDEN:
		return
	set_state(states.REVEALED)
	fog_sprite.hide()

func activate():
	cursor.hide()
	fog_sprite.hide()
	if state == states.ACTIVATED:
		return
	if activate_particles:
		activate_particles.emitting = true
	set_state(states.ACTIVATED)
	trigger_effect()

func set_state(new_state):
	state = new_state
	frame = frame_index_map[state]
	if state != states.HIDDEN and scan_result:
		scan_result.hide()
	if state != states.HIDDEN and temp_scan_tween:
		temp_scan_tween.kill()
		modulate = Color.WHITE

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if state != states.REVEALED:
		return
		
	if event.is_action_pressed("select"):
		activate()

func trigger_effect():
	print_debug("Not implemented")

func await_reveal(interval, done):
	if state == states.HIDDEN:
		set_state(states.REVEALED)
		interval += 0.15
	var tween = get_tree().create_tween()
	tween.tween_interval(interval)
	tween.tween_callback(done)

func set_scanned(temporary=false):
	if state == states.HIDDEN and scan_result:
		if temporary:
			temp_scan()
		else:
			permanent_scan()

func temp_scan():
	temp_scan_tween = scan_effect()
	temp_scan_tween.tween_property(self, "modulate", Color("#d5d1dc"), 0.05)
	temp_scan_tween.tween_interval(5)
	temp_scan_tween.tween_property(self, "modulate", Color.WHITE, 5)

func permanent_scan():
	scan_effect().tween_callback(show_scan_indicator)

func scan_effect():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color("#d5d1dc"), 0.05)
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate", Color("#d5d1dc"), 0.05)
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)
	tween.tween_interval(0.1)
	return tween

func show_scan_indicator():
	scan_result.show()
	scan_result.set_frame(0)
