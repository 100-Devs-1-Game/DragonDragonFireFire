class_name SceneDefinitions
extends RefCounted

enum Scenes
{
	UNDEFINED,
	TITLE_SCREEN,
	GAME_SCENE,
}

const TITLE_SCREEN_SCENE : PackedScene = preload("res://title_screen/title_screen.tscn")
const GAME_SCENE : PackedScene = preload("res://game_scene/game_scene.tscn")

const SCENE_DICT : Dictionary[Scenes, PackedScene] = {
	Scenes.UNDEFINED: null,
	Scenes.TITLE_SCREEN: TITLE_SCREEN_SCENE,
	Scenes.GAME_SCENE: GAME_SCENE,
}
