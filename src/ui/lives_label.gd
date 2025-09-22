class_name LivesLabel
extends Label


func _process(_delta : float) -> void:
	var lives_string = ""
	for i in GameState.lives:
		lives_string += "♥"

	text = lives_string
