# To be used as autoload, class name intentionally omitted.
extends Node

enum RenderMode
{
	CRT_SHADER_OFF,
	CRT_SHADER_TYPE1,
	CRT_SHADER_TYPE2,
	CRT_SHADER_TYPE3,
}

enum WindowMode
{
	WINDOWED,
	BORDERLESS,
	FULLSCREEN,
}

enum VsyncMode
{
	OFF,
	ON,
}

const _SETTINGS_PATH : String = "user://settings.cfg"

var cur_window_mode : WindowMode = WindowMode.WINDOWED
var cur_vsync_mode : VsyncMode = VsyncMode.ON
var render_mode : RenderMode = RenderMode.CRT_SHADER_TYPE1

var master_volume : float = 0.8
var music_volume : float = 0.8
var sound_volume : float = 0.8


func apply_window_mode():
	match(cur_window_mode):
		WindowMode.WINDOWED:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			# Note: Maximized counts as windowed for our purposes, so don't do anything in this case because it would
			# reset the maximized window to non maximized which the user doesn't want.
			if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		WindowMode.BORDERLESS:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func apply_vsync_mode():
	match(cur_vsync_mode):
		VsyncMode.OFF:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		VsyncMode.ON:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func apply_audio_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(sound_volume))


func read_settings_file():
	var settings_file : ConfigFile = ConfigFile.new()
	var error : Error = settings_file.load(_SETTINGS_PATH)
	if error != OK:
		push_warning("Not loading settings file, doesn't exist. Creating. This is expected on first run.")
		settings_file = ConfigFile.new()
		settings_file.save(_SETTINGS_PATH)
		return
	
	# --------------------------------------------------------------------------
	# Restore Window settings
	# --------------------------------------------------------------------------
	if settings_file.has_section_key("window_config", "window_mode"):
		var mode : int = settings_file.get_value("window_config", "window_mode")
		print("Setting to window mode " + str(mode) + " (size: " + str(WindowMode.size()) + ")")
		if mode < WindowMode.size():
			cur_window_mode = settings_file.get_value("window_config", "window_mode")
	else:
		push_warning("Config value missing: window_mode")

	if settings_file.has_section_key("window_config", "vsync_mode"):
		var mode : int = settings_file.get_value("window_config", "vsync_mode")
		print("Setting to vsync mode " + str(mode) + " (size: " + str(VsyncMode.size()) + ")")
		if mode < VsyncMode.size():
			cur_vsync_mode = settings_file.get_value("window_config", "vsync_mode")
	else:
		push_warning("Config value missing: vsync_mode")
	
	if settings_file.has_section_key("window_config", "render_mode"):
		var mode : int = settings_file.get_value("window_config", "render_mode")
		print("Setting to render mode " + str(mode) + " (size: " + str(RenderMode.size()) + ")")
		if mode < RenderMode.size():
			render_mode = settings_file.get_value("window_config", "render_mode")
	else:
		push_warning("Config value missing: render_mode")

	# --------------------------------------------------------------------------
	# Restore audio settings.
	# --------------------------------------------------------------------------
	if settings_file.has_section_key("audio_settings", "master_volume"):
		master_volume = settings_file.get_value("audio_settings", "master_volume")
	else:
		push_warning("Config value missing: master_volume")
		
	if settings_file.has_section_key("audio_settings", "music_volume"):
		music_volume = settings_file.get_value("audio_settings", "music_volume")
	else:
		push_warning("Config value missing: music_volume")
		
	if settings_file.has_section_key("audio_settings", "sound_volume"):
		sound_volume = settings_file.get_value("audio_settings", "sound_volume")
	else:
		push_warning("Config value missing: sound_volume")


func write_settings_file():
	var settings_file = ConfigFile.new()
	var error : Error = settings_file.load(_SETTINGS_PATH)
	if error != OK:
		push_warning("Settings file expected but doesn't exist. Creating new one.")
	
	settings_file.set_value("window_config", "window_mode", cur_window_mode)
	settings_file.set_value("window_config", "vsync_mode", cur_vsync_mode)
	settings_file.set_value("window_config", "render_mode", render_mode)
	
	settings_file.set_value("audio_settings", "master_volume", master_volume)
	settings_file.set_value("audio_settings", "music_volume", music_volume)
	settings_file.set_value("audio_settings", "sound_volume", sound_volume)
	
	settings_file.save(_SETTINGS_PATH)
