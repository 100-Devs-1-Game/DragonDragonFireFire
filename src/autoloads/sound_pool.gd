# To be used as autoload, class name intentionally omitted.
extends Node

const _STREAM_COUNT : int = 64
const _MAX_TRIES : int = 10

const SOUND_GAME_OVER_JINGLE : AudioStream = preload("res://assets/sounds/Game_Over_Jingle.ogg")

var _next_idx : int = 0
var _players : Array[AudioStreamPlayer]


func _ready() -> void:
	for i in _STREAM_COUNT:
		var instance : AudioStreamPlayer = AudioStreamPlayer.new()
		instance.bus = "Sound"
		_players.push_back(instance)
		add_child(instance)


func play_sound(sound : AudioStream) -> void:
	var num_tries : int = 0
	while num_tries < _MAX_TRIES:
		if not _players[_next_idx].playing:
			_players[_next_idx].stream = sound
			apply_custom_sound_volume(_players[_next_idx], sound)
			apply_pitch_modulation(_players[_next_idx], sound)
			_players[_next_idx].play()
			_next_idx = (_next_idx + 1) % _STREAM_COUNT
			break
		else:
			num_tries += 1
			_next_idx = (_next_idx + 1) % _STREAM_COUNT


func stop_sound(sound : AudioStream) -> void:
	for p in _players:
		if p.stream == sound:
			p.stop()


func stop_all_sounds():
	for p in _players:
		p.stop()


func apply_custom_sound_volume(player : AudioStreamPlayer, _sound : AudioStream) -> void:
	player.volume_db = 0.0
	# if sound == x:
	# 	player.volume_db = <+/-number>
	# 	return


func apply_pitch_modulation(player : AudioStreamPlayer, _sound : AudioStream):
	player.pitch_scale = 1.0

	# Modulate certain sounds.
	# if sound == sound_1 or \
	# 		sound == sound_2 or \
	# 		sound == sound_3:
	# 	player.pitch_scale = randf_range(0.97, 1.03)
	# 	return

	# Modulate certain other sounds only a tiny bit.
	# if sound == sound_4 or \
	# 		sound == sound_5:
	# 	player.pitch_scale = randf_range(0.996, 1.004)
	# 	return
