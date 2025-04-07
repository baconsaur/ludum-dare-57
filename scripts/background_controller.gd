extends Node2D

@export var speed = 500

func _process(delta: float) -> void:
	position.y += speed * delta
