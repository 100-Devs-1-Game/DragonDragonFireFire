# To be used as autoload, class name intentionally omitted.
extends Node

const _STREAM_COUNT : int = 64
const _MAX_TRIES : int = 10

const SOUND_COLLECTIBLE_PICKED_UP : AudioStream = preload("res://assets/sounds/Pickup_SFX_1.wav")
const SOUND_ENEMY_DEATH : AudioStream = preload("res://assets/sounds/Enemy_Death_SFX_1.wav")
const SOUND_ENEMY_SET_ON_FIRE : AudioStream = preload("res://assets/sounds/Enemy_Set_On_Fire_SFX.wav")
const SOUND_FIRE_SHOT : AudioStream = preload("res://assets/sounds/Fire_Shoot_SFX_1.wav")
const SOUND_GAME_OVER_JINGLE : AudioStream = preload("res://assets/sounds/Game_Over_Jingle.ogg")
const SOUND_LIFE_LOST : AudioStream = preload("res://assets/sounds/Player_Return_to_Position_v2.wav")
const SOUND_MENU_SELECT : AudioStream = preload("res://assets/sounds/Menu_Select_2.wav")
const SOUND_MENU_SWITCH : AudioStream = preload("res://assets/sounds/Menu_Sound_2.wav")
const SOUND_PLAYER_DROP_PLATFORM : AudioStream = preload("res://assets/sounds/Drop_Platform_SFX_2.wav")
const SOUND_PLAYER_HURT : AudioStream = preload("res://assets/sounds/Enemy_Impact_SFX.wav")
const SOUND_PLAYER_JUMP : AudioStream = preload("res://assets/sounds/Jump_SFX_1.wav")
const SOUND_STAGE_COMPLETED : AudioStream = preload("res://assets/sounds/Completed_SFX_1.wav")

const GLOBAL_SOUND_VOLUME_DB : float = -6.0

const VOLUME_CHANGE_DICT : Dictionary[AudioStream, float] = {
	SOUND_COLLECTIBLE_PICKED_UP: 0.0,
	SOUND_ENEMY_DEATH: -2.0,
	SOUND_FIRE_SHOT: -2.0,
	SOUND_GAME_OVER_JINGLE: 3.0,
	SOUND_LIFE_LOST: 5.0,
	SOUND_MENU_SELECT: -1.0,
	SOUND_MENU_SWITCH: 0.0,
	SOUND_PLAYER_DROP_PLATFORM: 2.0,
	SOUND_PLAYER_HURT: 0.0,
	SOUND_PLAYER_JUMP: -2.0,
	SOUND_STAGE_COMPLETED: -5.0,
}

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


func apply_custom_sound_volume(player : AudioStreamPlayer, sound : AudioStream) -> void:
	player.volume_db = GLOBAL_SOUND_VOLUME_DB
	assert(sound in VOLUME_CHANGE_DICT)
	player.volume_db += VOLUME_CHANGE_DICT[sound]
