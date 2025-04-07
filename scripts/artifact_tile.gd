class_name ArtifactTile
extends BaseTile

@onready var sparkles = $Sparkles

func _ready() -> void:
	can_scan = true
	super._ready()

func trigger_effect():
	emit_signal("activated", "collect_artifact")

func reveal():
	#sparkles.show()
	super.reveal()
