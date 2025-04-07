class_name LightTile
extends BaseTile

func trigger_effect():
	emit_signal("activated", "illuminate")

func activate():
	await_reveal(0.1, done)

func done():
	super.activate()
