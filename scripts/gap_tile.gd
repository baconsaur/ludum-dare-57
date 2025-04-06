class_name GapTile
extends BaseTile

@onready var create_particles = $CreateParticles

func trigger_effect():
	cursor.hide()
	fog_sprite.hide()
	set_state(states.ACTIVATED)
	emit_signal("activated", "drop")

func create_gap():
	fog_sprite.hide()
	create_particles.emitting = true

func activate():
	await_reveal(0.1, trigger_effect)

func await_reveal(interval, done):
	var tween = get_tree().create_tween()
	if state == states.HIDDEN:
		tween.tween_interval(interval)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.35)
	tween.tween_interval(interval)
	tween.tween_callback(done)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if state == states.HIDDEN:
		return
		
	if event is InputEventMouseButton and event.is_pressed():
		activate()

func _process(delta: float) -> void:
	if state == states.HIDDEN:
		return
	check_cursor()
