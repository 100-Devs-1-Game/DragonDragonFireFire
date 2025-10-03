class_name ScoreLabel
extends Label

const _NUM_DIGITS : int = 0
const _MIN_TRANSITION_SPEED : float = 1000.0

var _cur_displayed_score : int = 0


func _process(delta : float) -> void:
	var score_float : float = float(GameState.score)
	var cur_displayed_score_float : float = float(_cur_displayed_score)
	var transition_speed : float = max(_MIN_TRANSITION_SPEED, abs(score_float - cur_displayed_score_float))
	_cur_displayed_score = int(move_toward(cur_displayed_score_float, score_float, transition_speed * delta))

	text = str(_cur_displayed_score).pad_zeros(_NUM_DIGITS)
