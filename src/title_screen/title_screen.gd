class_name TitleScreen
extends Control


func _process(_delta : float) -> void:
	var accept_pressed : bool = Input.is_action_just_pressed("ui_accept")
	var jump_pressed : bool = Input.is_action_just_pressed("jump")
	var fire_pressed : bool = Input.is_action_just_pressed("fire")
	if accept_pressed or jump_pressed or fire_pressed:
		Signals.scene_change_triggered.emit(SceneDefinitions.Scenes.GAME_SCENE)
