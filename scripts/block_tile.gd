class_name BlockTile
extends BaseTile

@onready var wall = $Wall

func _ready() -> void:
	wall.hide()
	super._ready()

func reveal():
	wall.show()
	super.reveal()

func trigger_effect():
	wall.show()

func check_cursor():
	pass
