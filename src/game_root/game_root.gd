class_name GameRoot
extends Node2D

# The node to which the game scenes will be attached as children.
@onready var _scene_container_node : Node = %SceneContainer


func _ready() -> void:
	Signals.scene_change_triggered.connect(_on_scene_change_triggered)
	Initialization.initialize()


func _on_scene_change_triggered(new_scene : SceneDefinitions.Scenes) -> void:
	assert(_scene_container_node.get_children().size() == 1)
	if not new_scene in SceneDefinitions.SCENE_DICT:
		push_error("Invalid scene requested: " + str(new_scene))
		return

	_scene_container_node.get_child(0).queue_free()
	var next_scene = SceneDefinitions.SCENE_DICT[new_scene].instantiate()
	_scene_container_node.add_child(next_scene)
