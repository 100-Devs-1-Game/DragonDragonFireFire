class_name TimeController
extends Node


func _process(delta : float) -> void:
	if GameState.is_halted():
		return
	
	# Update the time left.
	GameState.time_left -= delta
