class_name MenuScreenSettingsMenu
extends MenuScreen

enum SelectedOption
{
	NONE,
	MASTER_VOLUME,
	EFFECTS_VOLUME,
	MUSIC_VOLUME,
}

enum Adjustment
{
	NONE,
	DECREASE,
	INCREASE,
}

const _VOLUME_STEP : float = 0.1

var _selected_option : SelectedOption = SelectedOption.NONE

@onready var _master_volume_bar : TextureProgressBar = $MasterVolumeBar
@onready var _effects_volume_bar : TextureProgressBar = $EffectsVolumeBar
@onready var _music_volume_bar : TextureProgressBar = $MusicVolumeBar


func _process(_delta : float) -> void:
	_handle_volume_change()
	_update_bars()


func _handle_volume_change() -> void:
	var adjustment : Adjustment = Adjustment.NONE
	if Input.is_action_just_pressed("ui_left"):
		adjustment = Adjustment.DECREASE
	elif Input.is_action_just_pressed("ui_right"):
		adjustment = Adjustment.INCREASE

	match _selected_option:
		SelectedOption.MASTER_VOLUME:
			if adjustment == Adjustment.INCREASE:
				Settings.master_volume = clamp(Settings.master_volume + _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
			elif adjustment == Adjustment.DECREASE:
				Settings.master_volume = clamp(Settings.master_volume - _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
		SelectedOption.EFFECTS_VOLUME:
			if adjustment == Adjustment.INCREASE:
				Settings.sound_volume = clamp(Settings.sound_volume + _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
			elif adjustment == Adjustment.DECREASE:
				Settings.sound_volume = clamp(Settings.sound_volume - _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
		SelectedOption.MUSIC_VOLUME:
			if adjustment == Adjustment.INCREASE:
				Settings.music_volume = clamp(Settings.music_volume + _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
			elif adjustment == Adjustment.DECREASE:
				Settings.music_volume = clamp(Settings.music_volume - _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()


func _update_bars() -> void:
	_master_volume_bar.value = Settings.master_volume
	_effects_volume_bar.value = Settings.sound_volume
	_music_volume_bar.value = Settings.music_volume


func _on_master_volume_button_focus_entered():
	_selected_option = SelectedOption.MASTER_VOLUME


func _on_effects_volume_button_focus_entered():
	_selected_option = SelectedOption.EFFECTS_VOLUME


func _on_music_volume_button_focus_entered():
	_selected_option = SelectedOption.MUSIC_VOLUME


func _on_back_button_focus_entered():
	_selected_option = SelectedOption.NONE


func _on_back_button_pressed():
	Settings.write_settings_file()
	Signals.menu_screen_requested.emit(MenuScreenDefinitions.MenuScreen.MAIN_MENU)
