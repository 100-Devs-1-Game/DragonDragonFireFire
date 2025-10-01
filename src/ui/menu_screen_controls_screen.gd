class_name MenuScreenControlsScreen
extends MenuScreen


func _process(_delta : float) -> void:
	if not is_active:
		return
	
	GameState.controls_shown = true
	
	var ui_accept_pressed : bool = Input.is_action_just_pressed("ui_accept")
	var fire_pressed : bool = Input.is_action_just_pressed("fire")
	var jump_pressed : bool = Input.is_action_just_pressed("jump")
	if ui_accept_pressed or fire_pressed or jump_pressed:
		Signals.play_game_requested.emit()
		SoundPool.play_sound(SoundPool.SOUND_MENU_SELECT)
