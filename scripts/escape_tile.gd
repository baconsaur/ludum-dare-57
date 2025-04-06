class_name EscapeTile
extends BaseTile

func trigger_effect():
	emit_signal("activated", "escape_level")
