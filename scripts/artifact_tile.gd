class_name ArtifactTile
extends BaseTile

@onready var sparkles = $Sparkles

func trigger_effect():
	emit_signal("activated", "collect_artifact")

func reveal():
	sparkles.show()
	super.reveal()
