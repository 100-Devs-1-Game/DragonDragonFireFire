class_name BurnableBlock
extends FallableGeometry

enum State
{
	DEFAULT,
	INCINERATING, # Fully burned down.
}

const _BURN_DESTROY_TIME : float = 3.0
const _DEATH_SEQUENCE_TIME : float = 0.17 # To be synched with incinerate shader animation.

var _cur_state : State = State.DEFAULT
var _incinerate_time_elapsed : float = 0.0

@onready var _visuals : Node2D = $Visuals
@onready var _burn_component : BurnComponent = $BurnComponent
@onready var _burn_visuals : Node2D = $Visuals/BurnVisuals


func _ready() -> void:
	_burn_visuals.visible = false

	# Assert that _visuals has its shader material attached.
	assert(_visuals.get("material") is ShaderMaterial)

	_assign_texture()


func _process(delta : float) -> void:
	if GameState.is_halted():
		return
	
	_burn_visuals.visible = _burn_component.is_burning()

	match _cur_state:
		State.DEFAULT:
			if _burn_component.is_burning() and _burn_component.get_burn_time() >= _BURN_DESTROY_TIME:
				_cur_state = State.INCINERATING
		State.INCINERATING:
			# Deactivate burn spreading and clear all collision layers.
			_burn_component.set_inactive()
			collision_layer = 0

			_incinerate_time_elapsed += delta
			_update_incinerate_visuals()

			if _incinerate_time_elapsed >= _DEATH_SEQUENCE_TIME:
				queue_free()


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		return
		
	# Only fall in default state.
	if _cur_state == State.DEFAULT:
		_handle_fall_logic(delta)


func _update_incinerate_visuals() -> void:
	var shader_material : ShaderMaterial = _visuals.get("material") as ShaderMaterial
	assert(shader_material)
	shader_material.set_shader_parameter("current_time", _incinerate_time_elapsed)


func _assign_texture() -> void:
	var selected_texture : Texture2D = GeometryColorDefinitions._BOX_TEXTURE_DICT[GameState.next_color]
	
	for child in _visuals.get_children():
		if child is Sprite2D:
			(child as Sprite2D).texture = selected_texture
