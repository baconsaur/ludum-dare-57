extends ProgressBar

var first_use = true
var is_active = false

@onready var highlight = $Highlight
@onready var highlight_anim = $Highlight/AnimationPlayer
@onready var button = $ScanButton

func _ready() -> void:
	button.connect("pressed", remove_tutorial)

func _on_value_changed(value: float) -> void:
	if not is_instance_valid(highlight):
		return
	if value >= max_value and first_use:
		is_active = true
		first_use = false
		highlight_anim.play("flash")
	elif value < max_value and is_active:
		is_active = false
		first_use = true
		highlight_anim.stop()
		highlight.hide()
			
func remove_tutorial():
	if not is_instance_valid(highlight):
		return
	is_active = false
	highlight.queue_free()
	button.disconnect("pressed", remove_tutorial)
