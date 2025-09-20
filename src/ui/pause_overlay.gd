class_name PauseOverlay
extends Control


func _process(_delta : float) -> void:
	visible = GameState.paused
