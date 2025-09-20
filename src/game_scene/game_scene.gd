class_name GameScene
extends Node2D


func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("menu"):
		GameState.paused = not GameState.paused
