class_name SolidTile
extends BaseTile

func _ready() -> void:
	can_scan = true
	super._ready()

func trigger_effect():
	emit_signal("activated", "reveal_neighbors")
