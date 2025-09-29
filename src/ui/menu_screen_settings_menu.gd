class_name MenuScreenSettingsMenu
extends MenuScreen

enum SelectedOption
{
	NONE,
	WINDOW_MODE,
	VSYNC_MODE,
	RENDER_MODE,
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

var _adjustment : Adjustment = Adjustment.NONE
var _selected_option : SelectedOption = SelectedOption.NONE

@onready var _window_mode_label : Label = $WindowModeLabel
@onready var _vsync_label : Label = $VSyncLabel
@onready var _render_mode_label : Label = $RenderModeLabel

@onready var _master_volume_bar : TextureProgressBar = $MasterVolumeBar
@onready var _effects_volume_bar : TextureProgressBar = $EffectsVolumeBar
@onready var _music_volume_bar : TextureProgressBar = $MusicVolumeBar


func _process(_delta : float) -> void:
	_update_adjustment()

	_handle_volume_change()
	_handle_display_change()

	_update_bars()
	_update_labels()


func _update_adjustment() -> void:
	_adjustment = Adjustment.NONE
	if Input.is_action_just_pressed("ui_left"):
		_adjustment = Adjustment.DECREASE
	elif Input.is_action_just_pressed("ui_right"):
		_adjustment = Adjustment.INCREASE

	if _adjustment != Adjustment.NONE:
		SoundPool.play_sound(SoundPool.SOUND_MENU_SWITCH)


func _handle_volume_change() -> void:
	match _selected_option:
		SelectedOption.MASTER_VOLUME:
			if _adjustment == Adjustment.INCREASE:
				Settings.master_volume = clamp(Settings.master_volume + _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
			elif _adjustment == Adjustment.DECREASE:
				Settings.master_volume = clamp(Settings.master_volume - _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
		SelectedOption.EFFECTS_VOLUME:
			if _adjustment == Adjustment.INCREASE:
				Settings.sound_volume = clamp(Settings.sound_volume + _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
			elif _adjustment == Adjustment.DECREASE:
				Settings.sound_volume = clamp(Settings.sound_volume - _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
		SelectedOption.MUSIC_VOLUME:
			if _adjustment == Adjustment.INCREASE:
				Settings.music_volume = clamp(Settings.music_volume + _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()
			elif _adjustment == Adjustment.DECREASE:
				Settings.music_volume = clamp(Settings.music_volume - _VOLUME_STEP, 0.0, 1.0)
				Settings.apply_audio_settings()


func _handle_display_change() -> void:
	if _selected_option == SelectedOption.WINDOW_MODE:
		var num_window_modes : int = Settings.WindowMode.size()
		if _adjustment == Adjustment.INCREASE:
			var new_mode : int = (Settings.cur_window_mode + 1) % num_window_modes
			Settings.cur_window_mode = new_mode as Settings.WindowMode
			Settings.apply_window_mode()
		elif _adjustment == Adjustment.DECREASE:
			var new_mode : int = (Settings.cur_window_mode - 1 + num_window_modes) % num_window_modes
			Settings.cur_window_mode = new_mode as Settings.WindowMode
			Settings.apply_window_mode()
	elif _selected_option == SelectedOption.VSYNC_MODE:
		var num_vsync_modes : int = Settings.VsyncMode.size()
		if _adjustment == Adjustment.INCREASE:
			var new_mode : int = (Settings.cur_vsync_mode + 1) % num_vsync_modes
			Settings.cur_vsync_mode = new_mode as Settings.VsyncMode
			Settings.apply_vsync_mode()
		elif _adjustment == Adjustment.DECREASE:
			var new_mode : int = (Settings.cur_vsync_mode - 1 + num_vsync_modes) % num_vsync_modes
			Settings.cur_vsync_mode = new_mode as Settings.VsyncMode
			Settings.apply_vsync_mode()
	elif _selected_option == SelectedOption.RENDER_MODE:
		var num_render_modes : int = Settings.RenderMode.size()
		if _adjustment == Adjustment.INCREASE:
			var new_mode : int = (Settings.render_mode + 1) % num_render_modes
			Settings.render_mode = new_mode as Settings.RenderMode
			# Does automatically apply.
		elif _adjustment == Adjustment.DECREASE:
			var new_mode : int = (Settings.render_mode - 1 + num_render_modes) % num_render_modes
			Settings.render_mode = new_mode as Settings.RenderMode
			# Does automatically apply.


func _update_bars() -> void:
	_master_volume_bar.value = Settings.master_volume
	_effects_volume_bar.value = Settings.sound_volume
	_music_volume_bar.value = Settings.music_volume


func _update_labels() -> void:
	match Settings.cur_window_mode:
		Settings.WindowMode.WINDOWED:
			_window_mode_label.text = "WINDOWED"
		Settings.WindowMode.BORDERLESS:
			_window_mode_label.text = "BORDERLESS"
		Settings.WindowMode.FULLSCREEN:
			_window_mode_label.text = "FULLSCREEN"
		_:
			push_error("Invalid window mode: " + str(Settings.cur_window_mode))

	match Settings.cur_vsync_mode:
		Settings.VsyncMode.OFF:
			_vsync_label.text = "OFF"
		Settings.VsyncMode.ON:
			_vsync_label.text = "ON"
		_:
			push_error("Invalid vsync mode: " + str(Settings.cur_vsync_mode))

	match Settings.render_mode:
		Settings.RenderMode.CRT_SHADER_OFF:
			_render_mode_label.text = "CRT EFFECT OFF"
		Settings.RenderMode.CRT_SHADER_TYPE1:
			_render_mode_label.text = "CRT EFFECT TYPE 1"
		Settings.RenderMode.CRT_SHADER_TYPE2:
			_render_mode_label.text = "CRT EFFECT TYPE 2"
		Settings.RenderMode.CRT_SHADER_TYPE3:
			_render_mode_label.text = "CRT EFFECT TYPE 3"
		_:
			push_error("Invalid render mode: " + str(Settings.render_mode))


func _on_window_mode_button_focus_entered():
	_selected_option = SelectedOption.WINDOW_MODE


func _on_v_sync_button_focus_entered():
	_selected_option = SelectedOption.VSYNC_MODE


func _on_render_mode_button_focus_entered():
	_selected_option = SelectedOption.RENDER_MODE


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
