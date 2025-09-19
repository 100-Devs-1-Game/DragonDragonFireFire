class_name ScoreLabel
extends Label


func _process(_delta : float) -> void:
	text = str(GameState.score)
