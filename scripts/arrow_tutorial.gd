extends Node2D

func _on_visibility_changed() -> void:
	if visible:
		get_parent().emit_signal("trigger_tutorial", "arrow")
