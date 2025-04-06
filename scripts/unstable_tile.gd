class_name UnstableTile
extends BaseTile

@export var gap_tile : PackedScene

func trigger_effect():
	emit_signal("activated", "destroy")
