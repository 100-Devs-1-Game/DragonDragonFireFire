class_name EndScreen
extends Control

enum State
{
	TRANSITION_IN,
	NEW_HIGHSCORE,
	WAITING_FOR_INPUT,
	TRANSITION_OUT,
}

const _NUM_INITIALS : int = 3
const _MAX_INITIALS_IDX : int = _NUM_INITIALS + 1 # +1 for OK label.

const _ANIMATION_GRACE_TIME = 0.2 # Don't start animation immediately to let all physics properly settle first.

var _animation_started : bool = false

var _cur_state : State = State.TRANSITION_IN
var _transition_time : float = 0.0
var _is_new_highscore : bool = false

var _selected_initial_idx : int = 0
var _entered_name : String = "---"

@onready var _transition_rect : TextureRect = $TransitionRect

@onready var _player_actor : PlayerActor = $PlayerActor

@onready var _new_highscore_screen : Control = %NewHighscoreScreen
@onready var _statistics_screen : Control = %StatisticsScreen

@onready var _initials : Array = [%Initial0, %Initial1, %Initial2]
@onready var _ok_label : OKLabel = %OKLabel

@onready var _stages_cleared_label : Label = %StagesCleared
@onready var _playtime_label : Label = %Playtime
@onready var _food_eaten_label : Label = %FoodEaten


func _ready() -> void:
	assert(_transition_rect.material)
	_transition_rect.material.set_shader_parameter("clear_progress", 0.0)

	_set_statistics()

	_is_new_highscore = Highscores.is_top_three_score(GameState.score)

	if _is_new_highscore:
		_new_highscore_screen.visible = true
		_statistics_screen.visible = false
	else:
		_new_highscore_screen.visible = false
		_statistics_screen.visible = true
	
	_selected_initial_idx = 0
	_update_initials_selection()

	GameState.cutscene = true
	GameState.paused = false


func _process(delta : float) -> void:
	match _cur_state:
		State.TRANSITION_IN:
			_process_transition_in(delta)
		State.NEW_HIGHSCORE:
			_process_new_highscore(delta)
		State.WAITING_FOR_INPUT:
			_process_waiting_for_input(delta)
		State.TRANSITION_OUT:
			_process_transition_out(delta)


func _set_statistics() -> void:
	_stages_cleared_label.text = str(GameState.current_stage - 1)
	_food_eaten_label.text = str(GameState.food_eaten)
	
	@warning_ignore("integer_division") # Intended.
	var hours : int = int(GameState.playtime_elapsed) / 3600
	@warning_ignore("integer_division") # Intended.
	var minutes : int = (int(GameState.playtime_elapsed) % 3600) / 60
	var seconds : int = int(GameState.playtime_elapsed) % 60

	_playtime_label.text = ""
	if hours > 0:
		_playtime_label.text += str(hours).pad_zeros(2) + ":"
	_playtime_label.text += str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)


func _process_transition_in(delta : float) -> void:
	_transition_time += delta
	_transition_rect.material.set_shader_parameter("clear_progress", _transition_time)

	if not _animation_started and _transition_time >= _ANIMATION_GRACE_TIME:
		GameState.cutscene = false # To have enemies move.
		_player_actor.play_end_screen_sequence()
		_animation_started = true

	if _transition_time >= 1.0:
		_cur_state = State.NEW_HIGHSCORE if _is_new_highscore else State.WAITING_FOR_INPUT
		_transition_time = 0.0


func _process_new_highscore(_delta : float) -> void:
	var fire_pressed : bool = Input.is_action_just_pressed("fire")
	var jump_pressed : bool = Input.is_action_just_pressed("jump")
	var ui_accept_pressed : bool = Input.is_action_just_pressed("ui_accept")
	if (fire_pressed or jump_pressed or ui_accept_pressed) and _selected_initial_idx == _MAX_INITIALS_IDX - 1:
		_entered_name = ""
		for i in range(_NUM_INITIALS):
			_entered_name += _initials[i].get_letter()

		assert(_entered_name.length() == _NUM_INITIALS)
		assert(Highscores.is_top_three_score(GameState.score))

		var score_entry : Highscores.ScoreEntry = Highscores.ScoreEntry.new()
		score_entry.score_value = GameState.score
		score_entry.name = _entered_name
		Highscores.add_score_entry(score_entry)

		_new_highscore_screen.visible = false
		_statistics_screen.visible = true
		_cur_state = State.WAITING_FOR_INPUT

	var ui_right_pressed : bool = Input.is_action_just_pressed("ui_right")
	if ui_right_pressed or fire_pressed or jump_pressed or ui_accept_pressed:
		_selected_initial_idx += 1
		_selected_initial_idx = min(_selected_initial_idx, _MAX_INITIALS_IDX - 1)
		_update_initials_selection()
	
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_cancel"):
		_selected_initial_idx -= 1
		_selected_initial_idx = max(_selected_initial_idx, 0)
		_update_initials_selection()
	
	if Input.is_action_just_pressed("ui_up"):
		if _selected_initial_idx < _NUM_INITIALS:
			assert(_initials[_selected_initial_idx].is_selected())
			_initials[_selected_initial_idx].next_letter()
	
	if Input.is_action_just_pressed("ui_down"):
		if _selected_initial_idx < _NUM_INITIALS:
			assert(_initials[_selected_initial_idx].is_selected())
			_initials[_selected_initial_idx].previous_letter()


func _process_waiting_for_input(_delta : float) -> void:
	var accept_pressed : bool = Input.is_action_just_pressed("ui_accept")
	var jump_pressed : bool = Input.is_action_just_pressed("jump")
	var fire_pressed : bool = Input.is_action_just_pressed("fire")
	if accept_pressed or jump_pressed or fire_pressed:
		Highscores.save_highscores_file()
		_cur_state = State.TRANSITION_OUT


func _process_transition_out(delta : float) -> void:
	_transition_time += delta
	_transition_rect.material.set_shader_parameter("clear_progress", 1.0 - _transition_time)

	if _transition_time >= 1.0:
		Signals.scene_change_triggered.emit(SceneDefinitions.Scenes.TITLE_SCREEN)


func _update_initials_selection() -> void:
	assert(_selected_initial_idx >= 0 and _selected_initial_idx < _MAX_INITIALS_IDX)

	for i in range(_NUM_INITIALS):
		_initials[i].set_selected(i == _selected_initial_idx)

	_ok_label.set_selected(_selected_initial_idx == _MAX_INITIALS_IDX - 1)
