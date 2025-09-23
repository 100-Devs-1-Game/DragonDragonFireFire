class_name TimeController
extends Node

var _timer_running : bool = false
var _timeout_signalled : bool = false


func _process(delta : float) -> void:
	if GameState.is_paused(): # Intentionally not during cutscene.
		return

	if not _timer_running:
		return
	
	# Update the time left.
	GameState.time_left -= delta
	GameState.playtime_elapsed += delta

	if GameState.time_left <= 0.0 and not _timeout_signalled:
		_timeout_signalled = true
		Signals.time_over.emit()


func set_running(value : bool) -> void:
	_timer_running = value
