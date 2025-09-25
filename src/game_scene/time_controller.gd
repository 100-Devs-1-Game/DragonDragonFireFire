class_name TimeController
extends Node

const _BONUS_SECONDS_GRANT_CADENCE : float = 0.15

var _timer_running : bool = false
var _timeout_signalled : bool = false

var _bonus_seconds_timer : float = 0.0


func _process(delta : float) -> void:
	if GameState.is_paused(): # Intentionally not during cutscene.
		return
	
	# Bonus seconds are also granted while timer is not running.
	_grant_bonus_seconds(delta)
	if GameState.time_left > Constants.MAX_PLAY_TIME:
		GameState.time_left = Constants.MAX_PLAY_TIME

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


func _grant_bonus_seconds(delta : float) -> void:
	if GameState.bonus_seconds <= 0:
		return
	
	_bonus_seconds_timer += delta
	if _bonus_seconds_timer >= _BONUS_SECONDS_GRANT_CADENCE:
		_bonus_seconds_timer -= _BONUS_SECONDS_GRANT_CADENCE
		GameState.time_left += 1.0
		GameState.bonus_seconds -= 1
