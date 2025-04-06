class_name GapTile
extends BaseTile

@onready var create_particles = $CreateParticles

func trigger_effect():
	emit_signal("activated", "drop")

func create_gap():
	create_particles.emitting = true

func activate():
	set_state(states.ACTIVATED)
	trigger_effect()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if state == states.HIDDEN:
		return
		
	if event is InputEventMouseButton and event.is_pressed():
		activate()
