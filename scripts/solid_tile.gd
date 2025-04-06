class_name SolidTile
extends BaseTile

func trigger_effect():
	emit_signal("activated", "reveal_neighbors")
