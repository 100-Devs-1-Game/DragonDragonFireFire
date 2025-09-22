# Class name intentionally omitted, intended to be used as Autoload.
extends Node

signal scene_change_triggered(new_scene : SceneDefinitions.Scenes)

signal player_died()

signal fire_emitted(burn_parameters : BurnParameters)
