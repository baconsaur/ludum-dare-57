class_name ScanTile
extends BaseTile

func trigger_effect():
	emit_signal("activated", "scan_area")
