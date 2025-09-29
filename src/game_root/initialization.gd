class_name Initialization
extends RefCounted


static func initialize() -> void:
	# Read highscores file.
	Highscores.read_highscores_file()

	# Read settings file.
	Settings.read_settings_file()

	# Apply settings.
	Settings.apply_window_mode()
	Settings.apply_vsync_mode()
	Settings.apply_audio_settings()
