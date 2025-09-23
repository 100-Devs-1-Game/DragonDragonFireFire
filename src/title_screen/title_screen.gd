class_name TitleScreen
extends Control

enum State
{
	TRANSITION_IN,
	WAITING_FOR_INPUT,
	TRANSITION_OUT,
}

var _cur_state : State = State.TRANSITION_IN
var _transition_time : float = 0.0

@onready var _transition_rect : TextureRect = $TransitionRect


func _ready() -> void:
	assert(_transition_rect.material)
	_transition_rect.material.set_shader_parameter("clear_progress", 0.0)


func _process(delta : float) -> void:
	match _cur_state:
		State.TRANSITION_IN:
			_process_transition_in(delta)
		State.WAITING_FOR_INPUT:
			_process_waiting_for_input(delta)
		State.TRANSITION_OUT:
			_process_transition_out(delta)


func _process_transition_in(delta : float) -> void:
	_transition_time += delta
	_transition_rect.material.set_shader_parameter("clear_progress", _transition_time)

	if _transition_time >= 1.0:
		_transition_time = 0.0
		_cur_state = State.WAITING_FOR_INPUT


func _process_waiting_for_input(_delta : float) -> void:
	var accept_pressed : bool = Input.is_action_just_pressed("ui_accept")
	var jump_pressed : bool = Input.is_action_just_pressed("jump")
	var fire_pressed : bool = Input.is_action_just_pressed("fire")
	if accept_pressed or jump_pressed or fire_pressed:
		_cur_state = State.TRANSITION_OUT


func _process_transition_out(delta : float) -> void:
	_transition_time += delta
	_transition_rect.material.set_shader_parameter("clear_progress", 1.0 - _transition_time)

	if _transition_time >= 1.0:
		_transition_time = 0.0
		Signals.scene_change_triggered.emit(SceneDefinitions.Scenes.GAME_SCENE)
