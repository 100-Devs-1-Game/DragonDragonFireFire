class_name TimeController
extends Node

var _timer_running : bool = false


func _process(delta : float) -> void:
	if GameState.is_halted():
		return

	if not _timer_running:
		return
	
	# Update the time left.
	GameState.time_left -= delta


func set_running(value : bool) -> void:
	_timer_running = value
