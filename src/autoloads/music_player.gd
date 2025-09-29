# To be used as autoload, class name intentionally omitted.
extends Node

const _STREAM_COUNT : int = 4
const _MIN_VOLUME_DB : float = -80.0

const TRACK_TITLE : AudioStream = preload("res://assets/music/Title_Music_1.ogg")
const TRACK_STAGE: AudioStream = preload("res://assets/music/Stage_1_Music_v3.ogg")

var _curr_idx : int = 0
var _players : Array[AudioStreamPlayer]


func _ready() -> void:
	for i in _STREAM_COUNT:
		var instance : AudioStreamPlayer = AudioStreamPlayer.new()
		instance.bus = "Music"
		_players.push_back(instance)
		add_child(instance)


func stop_track(duration : float = 0.0) -> void:
	# Start to fade the current track.
	var fade_tween : Tween = get_tree().create_tween()
	fade_tween.tween_property(_players[_curr_idx], "volume_db", _MIN_VOLUME_DB, duration)
	fade_tween.tween_callback(_players[_curr_idx].stop)

	# Increase index to not overwrite fading track.
	_curr_idx = (_curr_idx + 1) % _STREAM_COUNT


func play_track(track : AudioStream) -> void:
	# Stop potentially playing track immediately.
	_players[_curr_idx].stop()
	_players[_curr_idx].volume_db = 0.0 # Reset volume.

	# Start the new track.
	_players[_curr_idx].stream = track
	_players[_curr_idx].play()
