class_name MenuScreenCreditsScreen
extends MenuScreen


func _on_back_button_pressed():
	Signals.menu_screen_requested.emit(MenuScreenDefinitions.MenuScreen.MAIN_MENU)
