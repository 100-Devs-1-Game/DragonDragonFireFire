class_name Initialization
extends RefCounted


static func initialize() -> void:
	# Read highscores file.
	Highscores.read_highscores_file()
