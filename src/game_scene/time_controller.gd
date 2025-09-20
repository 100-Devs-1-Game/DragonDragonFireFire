class_name TimeController
extends Node


func _process(delta : float) -> void:
	# Update the time left.
	GameState.time_left -= delta
