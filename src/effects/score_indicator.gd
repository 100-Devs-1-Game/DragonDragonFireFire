class_name ScoreIndicator
extends Label

const _DURATION_FULLY_VISIBLE : float = 0.3
const _DURATION_FADE_OUT : float = 0.2
const _Y_OFFSET : float = 12.0

const _MOTION : Vector2 = Vector2(0, -8.0)

var _score_value : int = 0
var _lifetime : float = 0.0


func set_score(value : int) -> void:
	if value < 0:
		push_error("Score value cannot be negative.")
		return

	_score_value = value


func set_spawn_position(pos : Vector2) -> void:
	global_position = pos
	global_position -= size * 0.5
	global_position.y -= _Y_OFFSET


func _process(delta : float) -> void:
	if GameState.paused:
		return
	
	position += _MOTION * delta
	_lifetime += delta
	text = str(_score_value)

	if _lifetime < _DURATION_FULLY_VISIBLE:
		modulate.a = 1.0
	elif _lifetime < _DURATION_FULLY_VISIBLE + _DURATION_FADE_OUT:
		modulate.a = 1.0 - (_lifetime - _DURATION_FULLY_VISIBLE) / _DURATION_FADE_OUT
	else:
		queue_free()
