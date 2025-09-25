class_name MenuScreenMainMenu
extends MenuScreen


func _on_play_button_pressed():
	Signals.play_game_requested.emit()


func _on_exit_button_pressed():
	Signals.exit_game_requested.emit()
