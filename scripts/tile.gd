class_name BaseTile
extends Sprite2D

signal activated

enum states {HIDDEN, REVEALED, ACTIVATED}

@export var frame_index_map : Dictionary[states, int] = {
	states.HIDDEN: 0,
	states.REVEALED: 0,
	states.ACTIVATED: 0,
}
var state = states.HIDDEN
var activate_particles : CPUParticles2D

func _ready() -> void:
	activate_particles = find_child("ActivateParticles")
	set_state(states.HIDDEN)

func reveal():
	if state != states.HIDDEN:
		return
	set_state(states.REVEALED)

func activate():
	if state == states.ACTIVATED:
		return
	if activate_particles:
		activate_particles.emitting = true
	set_state(states.ACTIVATED)
	trigger_effect()

func set_state(new_state):
	state = new_state
	frame = frame_index_map[state]

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if state != states.REVEALED:
		return
		
	if event is InputEventMouseButton and event.is_pressed():
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
