class_name ScoreLabel
extends Label

const _NUM_DIGITS : int = 0
const _TRANSITION_SPEED : float = 500.0

var _cur_displayed_score : int = 0


func _process(delta : float) -> void:
	var score_float : float = float(GameState.score)
	var cur_displayed_score_float : float = float(_cur_displayed_score)
	_cur_displayed_score = int(move_toward(cur_displayed_score_float, score_float, _TRANSITION_SPEED * delta))

	text = str(_cur_displayed_score).pad_zeros(_NUM_DIGITS)
