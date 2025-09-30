class_name GameScene
extends Node2D

enum State
{
	INTRO,
	PLAYING,
	TRANSITION_ENTERING,
	TRANSITIONING,
	PLAYER_DEAD,
}

const _PLAYER_SCENE : PackedScene = preload("res://player/player.tscn")

# Grace time to not have a sudden transition immediately after last enemy is defeated.
const _TRANSITION_ENTERING_TIME : float = 2.5

var _transition_entering_time_elapsed : float = 0.0

var _cur_state : State = State.INTRO
var _next_stage : Stage = null # Reference to where next stage will be instantiated.

var _current_stage_starting_pos : Vector2 = Vector2.ZERO

@onready var _player_cutscene : PlayerCutscene = $PlayerCutscene
@onready var _transition_rect : TextureRect = $TransitionRect
@onready var _game_over_label : Label = $GameOverLabel
@onready var _time_controller : TimeController = $TimeController
@onready var _enemy_controller : EnemyController = $EnemyController

@onready var _current_stage : Stage = $Stage1


func _init() -> void:
	# Pick the first color fixed pink.
	GameState.next_color = GeometryColorDefinitions.Colors.BLUE


func _ready() -> void:
	GameState.reset_game_state()

	Signals.player_died.connect(_on_player_died)
	Signals.time_over.connect(_on_time_over)

	GameState.cutscene = true
	_player_cutscene.z_index = 1 # Visible above transition.

	assert(_transition_rect.material)
	_transition_rect.material.set_shader_parameter("clear_progress", 0.0)

	_game_over_label.visible = false
	_game_over_label.visible_ratio = 0.0

	_play_intro_sequence()


func _process(delta : float) -> void:
	match _cur_state:
		State.INTRO:
			pass

		State.PLAYING:
			if Input.is_action_just_pressed("menu") and not GameState.is_in_cutscene():
				GameState.paused = not GameState.paused

			if _enemy_controller.get_enemy_count() == 0:
				Signals.transition_to_next_stage_started.emit()
				_transition_entering_time_elapsed = 0.0
				_cur_state = State.TRANSITION_ENTERING

		State.TRANSITION_ENTERING:
			_time_controller.set_running(false) # Stop timer during transition enter stage, would be unfair not to.
			_transition_entering_time_elapsed += delta
			if _transition_entering_time_elapsed >= _TRANSITION_ENTERING_TIME:
				_current_stage.grant_completion_bonus()
				_cur_state = State.TRANSITIONING
				_transition_stages()

		State.TRANSITIONING:
			pass
		
		State.PLAYER_DEAD:
			pass


func _play_intro_sequence() -> void:
	var player : Player = _current_stage.get_player() # The actual player in the stage.
	_current_stage_starting_pos = player.global_position # TODO: Starting pos handling is stage responsibility.
	player.visible = false

	_time_controller.set_running(false)
	_jumpstart_stage_music()

	var intro_tween : Tween = get_tree().create_tween()
	intro_tween.tween_callback(_player_cutscene.play_body.bind("walk"))
	intro_tween.tween_callback(_player_cutscene.play_head.bind("normal"))
	intro_tween.tween_property(_player_cutscene, "global_position", player.global_position, 0.7)
	intro_tween.tween_callback(_player_cutscene.play_body.bind("idle"))
	intro_tween.tween_callback(_player_cutscene.play_head.bind("normal"))
	intro_tween.tween_interval(0.1)
	intro_tween.tween_callback(_player_cutscene.play_body.bind("cheer"))
	intro_tween.tween_callback(_player_cutscene.play_head.bind("invisible"))
	intro_tween.tween_property(_transition_rect, "material:shader_parameter/clear_progress", 1.0, 0.75)
	intro_tween.tween_callback(_player_cutscene.play_body.bind("idle"))
	intro_tween.tween_callback(_player_cutscene.play_head.bind("normal"))
	intro_tween.tween_interval(0.3)
	intro_tween.tween_callback(_callback_intro_finished)


func _callback_intro_finished() -> void:
	var player : Player = _current_stage.get_player()
	player.visible = true

	_player_cutscene.visible = false
	_player_cutscene.z_index = 0 # Reset back to zero.
	_cur_state = State.PLAYING
	GameState.cutscene = false
	_time_controller.set_running(true)
 
	_current_stage.do_setup()


func _jumpstart_stage_music() -> void:
	await get_tree().create_timer(0.28).timeout
	MusicPlayer.play_track(MusicPlayer.TRACK_STAGE)


func _transition_stages() -> void:
	_cur_state = State.TRANSITIONING
	GameState.cutscene = true

	GameState.current_stage += 1

	# Cycle through stage colors.
	var num_colors : int = GeometryColorDefinitions.Colors.size()
	GameState.next_color = (int(GameState.next_color) + 1) % num_colors as GeometryColorDefinitions.Colors

	# Determine the next stage to load, rotating cyclically through the available stages.
	var num_stages : int = StageDefinitions.STAGES_DICT.size()
	var next_stage_number : int = (GameState.current_stage - 1) % num_stages + 1 # Stages are 1-indexed.

	_next_stage = StageDefinitions.STAGES_DICT[next_stage_number].instantiate()
	add_child(_next_stage)
	move_child(_next_stage, 0)
	_next_stage.global_position = Vector2(0, -Constants.ARENA_HEIGHT)

	var player : Player = _current_stage.get_player()
	_player_cutscene.global_position = player.global_position
	_player_cutscene.play_body("spin")
	_player_cutscene.play_head("invisible")
	_player_cutscene.visible = true
	player.visible = false
	var next_stage_player : Player = _next_stage.get_player()
	next_stage_player.visible = false
	var player_target_pos : Vector2 = next_stage_player.global_position + Vector2(0, Constants.ARENA_HEIGHT)

	GameState.bonus_seconds += Constants.BONUS_SECONDS_PER_COMPLETED_STAGE
	SoundPool.play_sound(SoundPool.SOUND_STAGE_COMPLETED)

	var transition_tween : Tween = get_tree().create_tween()
	transition_tween.set_parallel(true)
	transition_tween.tween_property(_next_stage, "global_position", Vector2(0, 0), 2.0)
	transition_tween.tween_property(_current_stage, "global_position", Vector2(0, Constants.ARENA_HEIGHT), 2.0)
	transition_tween.tween_property(_player_cutscene, "global_position", player_target_pos, 2.0)

	transition_tween.set_parallel(false)
	transition_tween.tween_callback(_callback_transition_finished)


func _callback_transition_finished() -> void:
	_current_stage.queue_free()
	_current_stage = _next_stage
	_next_stage = null

	var player : Player = _current_stage.get_player()
	_current_stage_starting_pos = player.global_position
	player.visible = true
	_player_cutscene.visible = false

	_cur_state = State.PLAYING
	GameState.cutscene = false
	_time_controller.set_running(true)

	_current_stage.do_setup()


func _on_player_died() -> void:
	assert(_cur_state != State.PLAYER_DEAD)
	_cur_state = State.PLAYER_DEAD
	SoundPool.play_sound(SoundPool.SOUND_PLAYER_HURT)

	GameState.cutscene = true
	_time_controller.set_running(false)

	var player : Player = _current_stage.get_player()
	_player_cutscene.global_position = player.global_position

	_player_cutscene.play_body("hurt")
	_player_cutscene.play_head("invisible")
	_player_cutscene.visible = true
	player.visible = false

	GameState.lives -= 1
	if GameState.lives <= 0:
		_game_over_label.visible = true
		_game_over_label.text = "GAME OVER!"
		_do_game_over_transition()
	else:
		_do_death_transition()


func _on_time_over() -> void:
	_cur_state = State.PLAYER_DEAD
	SoundPool.play_sound(SoundPool.SOUND_PLAYER_HURT)

	GameState.cutscene = true
	_time_controller.set_running(false)

	var player : Player = _current_stage.get_player()
	_player_cutscene.global_position = player.global_position

	_player_cutscene.play_body("hurt")
	_player_cutscene.play_head("invisible")
	_player_cutscene.visible = true
	player.visible = false

	_game_over_label.visible = true
	_game_over_label.text = "TIME OVER!"
	_do_game_over_transition()


func _do_death_transition() -> void:
	var death_transition_tween : Tween = get_tree().create_tween()
	death_transition_tween.tween_interval(0.75)
	death_transition_tween.tween_callback(SoundPool.play_sound.bind(SoundPool.SOUND_LIFE_LOST))
	death_transition_tween.tween_callback(_player_cutscene.play_body.bind("spin_hurt"))
	death_transition_tween.tween_callback(_player_cutscene.play_head.bind("invisible"))
	death_transition_tween.tween_property(_player_cutscene, "global_position", _current_stage_starting_pos, 1.5)
	death_transition_tween.tween_callback(_player_cutscene.play_body.bind("idle"))
	death_transition_tween.tween_callback(_player_cutscene.play_head.bind("normal"))
	death_transition_tween.tween_interval(0.5)
	death_transition_tween.tween_callback(_callback_death_transition_finished)


func _callback_death_transition_finished() -> void:
	var player : Player = _current_stage.get_player()
	player.queue_free()

	var new_player : Player = _PLAYER_SCENE.instantiate()
	_current_stage.add_child(new_player)
	_current_stage.set_player(new_player)

	new_player.grant_invincibility()

	new_player.global_position = _current_stage_starting_pos
	new_player.visible = true
	_player_cutscene.visible = false

	_cur_state = State.PLAYING
	GameState.cutscene = false
	_time_controller.set_running(true)


func _do_game_over_transition() -> void:
	MusicPlayer.stop_track(0.4)

	var transition_tween : Tween = get_tree().create_tween()
	transition_tween.set_parallel(true)
	transition_tween.tween_property(_game_over_label, "visible_ratio", 1.0, 0.2)
	transition_tween.tween_interval(0.9)
	transition_tween.set_parallel(false)
	transition_tween.tween_callback(SoundPool.play_sound.bind(SoundPool.SOUND_GAME_OVER_JINGLE))
	transition_tween.tween_interval(0.1)
	transition_tween.tween_callback(_player_cutscene.play_body.bind("spin_hurt"))
	transition_tween.tween_callback(_player_cutscene.play_head.bind("invisible"))
	transition_tween.tween_interval(0.8)
	transition_tween.tween_callback(_player_cutscene.pause)
	transition_tween.tween_property(_player_cutscene, "dissolve_shader_time", 0.6, 0.6)
	transition_tween.tween_property(_player_cutscene, "dissolve_shader_time", 0.0, 0.001)
	transition_tween.tween_callback(_player_cutscene.play_body.bind("explode"))
	transition_tween.tween_callback(_player_cutscene.play_head.bind("invisible"))
	transition_tween.tween_interval(0.8)
	transition_tween.tween_property(_transition_rect, "material:shader_parameter/clear_progress", 0.0, 0.75)
	transition_tween.tween_callback(_callback_game_over_transition_finished)


func _callback_game_over_transition_finished() -> void:
	Signals.scene_change_triggered.emit(SceneDefinitions.Scenes.END_SCREEN)
