# Class name intentionally omitted, intended to be used as Autoload.
extends Node

signal scene_change_triggered(new_scene : SceneDefinitions.Scenes)

signal menu_screen_requested(new_screen : MenuScreenDefinitions.MenuScreen)
signal play_game_requested()
signal exit_game_requested()

signal player_died()
signal time_over()
signal transition_to_next_stage_started()
signal fire_emitted(burn_parameters : BurnParameters)
signal bonus_collectible_spawn_triggered()
