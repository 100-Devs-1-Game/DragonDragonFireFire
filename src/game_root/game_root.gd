class_name GameRoot
extends Node2D

# The node to which the game scenes will be attached as children.
@onready var _scene_container_node : Node = %SceneContainer

# The viewport i.e. the internal stage of the game.
@onready var _game_viewport : Viewport = %GameViewport

@onready var _render_rect_shader : ColorRect = %RenderRectShader
@onready var _render_rect_no_shader : ColorRect = %RenderRectNoShader


func _ready() -> void:
	Signals.scene_change_triggered.connect(_on_scene_change_triggered)
	Initialization.initialize()


func _process(_delta : float) -> void:
	_update_shader_settings()


func _update_shader_settings() -> void:
	# CRT shader off.
	if Settings.render_mode == Settings.RenderMode.CRT_SHADER_OFF:
		_render_rect_shader.visible = false
		_render_rect_no_shader.visible = true
		return
	
	# CRT shader on.
	_render_rect_shader.visible = true
	_render_rect_no_shader.visible = false
	match Settings.render_mode:
		Settings.RenderMode.CRT_SHADER_TYPE1:
			_render_rect_shader.material.set_shader_parameter("mask_type", 3)
			_render_rect_shader.material.set_shader_parameter("curve", 0.091)
			_render_rect_shader.material.set_shader_parameter("sharpness", 0.714)

		Settings.RenderMode.CRT_SHADER_TYPE2:
			_render_rect_shader.material.set_shader_parameter("mask_type", 0)
			_render_rect_shader.material.set_shader_parameter("curve", 0.045)
			_render_rect_shader.material.set_shader_parameter("sharpness", 0.814)
		Settings.RenderMode.CRT_SHADER_TYPE3:
			_render_rect_shader.material.set_shader_parameter("mask_type", 5)
			_render_rect_shader.material.set_shader_parameter("curve", 0.073)
			_render_rect_shader.material.set_shader_parameter("sharpness", 0.803)
		_:
			push_error("Invalid render mode: " + str(Settings.render_mode))


func _unhandled_input(event: InputEvent) -> void:
	# Keyboard/gamepad -> pass through.
	if event is InputEventKey or event is InputEventJoypadButton:
		_game_viewport.push_input(event)


func _on_scene_change_triggered(new_scene : SceneDefinitions.Scenes) -> void:
	assert(_scene_container_node.get_children().size() == 1)
	if not new_scene in SceneDefinitions.SCENE_DICT:
		push_error("Invalid scene requested: " + str(new_scene))
		return

	_scene_container_node.get_child(0).queue_free()
	var next_scene = SceneDefinitions.SCENE_DICT[new_scene].instantiate()
	_scene_container_node.add_child(next_scene)
