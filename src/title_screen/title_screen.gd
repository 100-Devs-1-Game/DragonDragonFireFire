class_name TitleScreen
extends Control

enum TransitionState
{
	TRANSITION_IN,
	IDLE,
	TRANSITION_OUT,
}

enum LeaveScreenAction
{
	START_GAME,
	EXIT_GAME,
}

const _MUSIC_FADEOUT_TIME : float = 2.0


var _cur_transition_state : TransitionState = TransitionState.TRANSITION_IN
var _transition_time : float = 0.0

var _current_screen : MenuScreenDefinitions.MenuScreen = MenuScreenDefinitions.MenuScreen.UNDEFINED
var _leave_screen_action : LeaveScreenAction = LeaveScreenAction.START_GAME

@onready var _transition_rect : TextureRect = $TransitionRect

@onready var _menu_screen_insert_coin : MenuScreenInsertCoin = $MenuScreenContainer/MenuScreenInsertCoin
@onready var _menu_screen_main_menu : MenuScreenMainMenu = $MenuScreenContainer/MenuScreenMainMenu
@onready var _menu_screen_settings_menu : MenuScreenSettingsMenu = $MenuScreenContainer/MenuScreenSettingsMenu
@onready var _menu_screen_credits_screen : MenuScreenCreditsScreen = $MenuScreenContainer/MenuScreenCreditsScreen

@onready var _title_graphic_control : Control = $TitleGraphicControl


func _ready() -> void:
	Signals.menu_screen_requested.connect(_on_menu_screen_requested)
	Signals.play_game_requested.connect(_on_play_game_requested)
	Signals.exit_game_requested.connect(_on_exit_game_requested)

	_menu_screen_insert_coin.visible = false
	_menu_screen_main_menu.visible = false
	_menu_screen_settings_menu.visible = false
	_menu_screen_credits_screen.visible = false

	if GameState.title_shown:
		_current_screen = MenuScreenDefinitions.MenuScreen.MAIN_MENU
		_activate_menu_screen(MenuScreenDefinitions.MenuScreen.MAIN_MENU)
	else:
		_current_screen = MenuScreenDefinitions.MenuScreen.INSERT_COIN
		_activate_menu_screen(MenuScreenDefinitions.MenuScreen.INSERT_COIN)
		GameState.title_shown = true

	assert(_transition_rect.material)
	_transition_rect.material.set_shader_parameter("clear_progress", 0.0)

	MusicPlayer.play_track(MusicPlayer.TRACK_TITLE)


func _process(delta : float) -> void:
	_update_transition(delta)
	_update_title_graphic_visibility()


func _update_transition(delta : float) -> void:
	match _cur_transition_state:
		TransitionState.TRANSITION_IN:
			_process_transition_in(delta)
		TransitionState.IDLE:
			_process_transition_idle(delta)
		TransitionState.TRANSITION_OUT:
			_process_transition_out(delta)


func _update_title_graphic_visibility() -> void:
	if _current_screen == MenuScreenDefinitions.MenuScreen.CREDITS_SCREEN:
		_title_graphic_control.visible = false
	else:
		_title_graphic_control.visible = true


func _activate_menu_screen(new_screen : MenuScreenDefinitions.MenuScreen) -> void:
	match _current_screen:
		MenuScreenDefinitions.MenuScreen.INSERT_COIN:
			_menu_screen_insert_coin.deactivate()
		MenuScreenDefinitions.MenuScreen.MAIN_MENU:
			_menu_screen_main_menu.deactivate()
		MenuScreenDefinitions.MenuScreen.SETTINGS_MENU:
			_menu_screen_settings_menu.deactivate()
		MenuScreenDefinitions.MenuScreen.CREDITS_SCREEN:
			_menu_screen_credits_screen.deactivate()
		_:
			pass

	match new_screen:
		MenuScreenDefinitions.MenuScreen.INSERT_COIN:
			_menu_screen_insert_coin.activate()
		MenuScreenDefinitions.MenuScreen.MAIN_MENU:
			_menu_screen_main_menu.activate()
		MenuScreenDefinitions.MenuScreen.SETTINGS_MENU:
			_menu_screen_settings_menu.activate()
		MenuScreenDefinitions.MenuScreen.CREDITS_SCREEN:
			_menu_screen_credits_screen.activate()
		_:
			push_error("Invalid screen specified to activate: %s" % str(new_screen))
	
	_current_screen = new_screen


func _process_transition_in(delta : float) -> void:
	_transition_time += delta
	_transition_rect.material.set_shader_parameter("clear_progress", _transition_time)

	if _transition_time >= 1.0:
		_cur_transition_state = TransitionState.IDLE


func _process_transition_idle(_delta : float) -> void:
	_transition_time = 1.0


func _process_transition_out(delta : float) -> void:
	_transition_time -= delta
	_transition_rect.material.set_shader_parameter("clear_progress",  _transition_time)

	if _transition_time <= 0.0:
		if _leave_screen_action == LeaveScreenAction.START_GAME:
			Signals.scene_change_triggered.emit(SceneDefinitions.Scenes.GAME_SCENE)
		elif _leave_screen_action == LeaveScreenAction.EXIT_GAME:
			get_tree().quit()


func _on_menu_screen_requested(new_screen : MenuScreenDefinitions.MenuScreen) -> void:
	_activate_menu_screen(new_screen)


func _on_play_game_requested() -> void:
	_leave_screen_action = LeaveScreenAction.START_GAME
	_cur_transition_state = TransitionState.TRANSITION_OUT
	MusicPlayer.stop_track(_MUSIC_FADEOUT_TIME)
	_deactivate_all_menu_screens()


func _on_exit_game_requested() -> void:
	_leave_screen_action = LeaveScreenAction.EXIT_GAME
	_cur_transition_state = TransitionState.TRANSITION_OUT
	MusicPlayer.stop_track(_MUSIC_FADEOUT_TIME)
	_deactivate_all_menu_screens()


func _deactivate_all_menu_screens() -> void:
	_menu_screen_insert_coin.deactivate()
	_menu_screen_main_menu.deactivate()
	_menu_screen_settings_menu.deactivate()
	_menu_screen_credits_screen.deactivate()
