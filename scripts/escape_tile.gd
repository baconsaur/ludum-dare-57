class_name EscapeTile
extends BaseTile

@onready var portal = $Portal

func _ready() -> void:
	portal.hide()
	super._ready()

func trigger_effect():
	emit_signal("activated", "escape_level")

func set_state(new_state):
	super.set_state(new_state)
	if new_state != states.HIDDEN:
		portal.show()
