# To be used as autoload, class name intentionally omitted.
extends Node

const _SETTINGS_PATH : String = "user://settings.cfg"

var master_volume : float = 0.8
var music_volume : float = 0.8
var sound_volume : float = 0.8


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
	
	settings_file.set_value("audio_settings", "master_volume", master_volume)
	settings_file.set_value("audio_settings", "music_volume", music_volume)
	settings_file.set_value("audio_settings", "sound_volume", sound_volume)
	
	settings_file.save(_SETTINGS_PATH)
