class_name UnstableTile
extends BaseTile

@export var gap_tile : PackedScene

func trigger_effect():
	emit_signal("activated", "destroy")

func activate():
	await_reveal(0.1, done)

func done():
	super.activate()
