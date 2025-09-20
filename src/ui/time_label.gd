class_name TimeLabel
extends Label

const _MIN_NUM_DIGITS : int = 2


func _process(_delta : float):
	# Draw time with leading zeros so that it is always num_digits long.
	var time_left_int : int = int(GameState.time_left)
	text = str(time_left_int).pad_zeros(_MIN_NUM_DIGITS)
