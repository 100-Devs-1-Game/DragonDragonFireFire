class_name MenuScreenInsertCoin
extends MenuScreen


func _process(_delta : float) -> void:
	if not is_active:
		return
	
	var ui_accept_pressed : bool = Input.is_action_just_pressed("ui_accept")
	var fire_pressed : bool = Input.is_action_just_pressed("fire")
	var jump_pressed : bool = Input.is_action_just_pressed("jump")
	if ui_accept_pressed or fire_pressed or jump_pressed:
		Signals.menu_screen_requested.emit(MenuScreenDefinitions.MenuScreen.MAIN_MENU)
