class_name GameScene
extends Node2D

enum State
{
	INTRO,
	PLAYING,
	TRANSITION,
}

var _cur_state : State = State.INTRO

@onready var _player_cutscene : PlayerCutscene = $PlayerCutscene
@onready var _transition_rect : TextureRect = $TransitionRect

@onready var _current_stage : Stage = $Stage1
var _next_stage : Stage = null


func _ready() -> void:
	GameState.cutscene = true

	assert(_transition_rect.material)
	_transition_rect.material.set_shader_parameter("clear_progress", 0.0)

	_play_intro_sequence()


func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("menu") and not GameState.is_in_cutscene():
		GameState.paused = not GameState.paused


func _play_intro_sequence() -> void:
	var player : Player = _current_stage.get_player() # The actual player in the stage.

	# TODO: Play walk animation.

	var intro_tween : Tween = get_tree().create_tween()
	intro_tween.tween_property(_player_cutscene, "global_position", player.global_position, 1.0)
	intro_tween.tween_interval(0.2)
	intro_tween.tween_property(_transition_rect, "material:shader_parameter/clear_progress", 1.0, 0.75)
	# TODO: Play cheer animation.
	intro_tween.tween_callback(Callable(self, "_callback_intro_finished"))


func _callback_intro_finished() -> void:
	_player_cutscene.visible = false
	_cur_state = State.PLAYING
	GameState.cutscene = false


func _transition_stages() -> void:
	_cur_state = State.TRANSITION
	GameState.cutscene = true

	_next_stage = StageDefinitions.STAGES_DICT[2].instantiate()
	add_child(_next_stage)
	move_child(_next_stage, 0)
	_next_stage.global_position = Vector2(0, -Constants.ARENA_HEIGHT)

	var player : Player = _current_stage.get_player()
	player.visible = false
	_player_cutscene.play("stage_transition")
	_player_cutscene.visible = true
	var next_stage_player : Player = _next_stage.get_player()
	var player_target_pos : Vector2 = next_stage_player.global_position + Vector2(0, Constants.ARENA_HEIGHT)

	var transition_tween : Tween = get_tree().create_tween()
	transition_tween.set_parallel(true)
	transition_tween.tween_property(_next_stage, "global_position", Vector2(0, 0), 2.0)
	transition_tween.tween_property(_current_stage, "global_position", Vector2(0, Constants.ARENA_HEIGHT), 2.0)
	transition_tween.tween_property(_player_cutscene, "global_position", player_target_pos, 2.0)
	
	transition_tween.set_parallel(false)
	transition_tween.tween_callback(Callable(_current_stage, "queue_free"))
