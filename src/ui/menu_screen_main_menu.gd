class_name MenuScreenMainMenu
extends MenuScreen


func _on_play_button_pressed():
	Signals.play_game_requested.emit()
	SoundPool.play_sound(SoundPool.SOUND_MENU_SELECT)


func _on_settings_button_pressed():
	Signals.menu_screen_requested.emit(MenuScreenDefinitions.MenuScreen.SETTINGS_MENU)


func _on_credits_button_pressed():
	Signals.menu_screen_requested.emit(MenuScreenDefinitions.MenuScreen.CREDITS_SCREEN)


func _on_exit_button_pressed():
	Signals.exit_game_requested.emit()
