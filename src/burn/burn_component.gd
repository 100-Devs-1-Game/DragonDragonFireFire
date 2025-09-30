class_name BurnComponent
extends Node2D

# Sometimes, due to frame timing, a burnable component (in particular enemies) might get incinerated immediately when
# in vicinity of another burning component like a box. I'm not exactly sure what that happens. To prevent it, we add
# a miniscule grace time. A component can only get incinerated after this time has passed since it started burning.
const _INCINERATION_GRACE_TIME : float = 0.03

var _is_burning : bool = false
var _is_incinerated : bool = false
var _burn_time : float = 0.0
var _time_since_last_tick : float = 0.0
var _hor_burn_flee_direction : Types.Direction = Types.Direction.LEFT
var _ver_burn_flee_direction : Types.Direction = Types.Direction.UP
var _is_player_induced : bool = false
var _inactive : bool = false

@export var _ignition_range : float = 0.0
@export var _force_immediate : bool = false

@export var _catch_fire_range : float = 0.0
@export var _catch_burn_time : float = 0.0


func _ready() -> void:
	Signals.fire_emitted.connect(_on_fire_emitted)


func _process(delta : float) -> void:
	if GameState.is_halted():
		return

	if not _is_burning:
		return
	
	if _inactive:
		return
	
	_burn_time += delta
	_time_since_last_tick += delta
	if _time_since_last_tick >= Constants.FIRE_TICK_TIME:
		var burn_params : BurnParameters = _make_burn_parameters()
		Signals.fire_emitted.emit(burn_params)
		_time_since_last_tick = 0.0


func is_burning() -> bool:
	return _is_burning


func is_incinerated() -> bool:
	return _is_incinerated


func get_burn_time() -> float:
	return _burn_time


func does_scare_enemies() -> bool:
	return _is_player_induced


func get_hor_burn_flee_direction() -> Types.Direction:
	return _hor_burn_flee_direction


func get_ver_burn_flee_direction() -> Types.Direction:
	return _ver_burn_flee_direction


func _make_burn_parameters() -> BurnParameters:
	var params : BurnParameters = BurnParameters.new()
	params.source_pos = global_position
	params.source_burn_time = _burn_time
	params.ignition_range = _ignition_range
	params.force_immediate = _force_immediate
	params.is_player_induced = false
	return params


func set_inactive() -> void:
	_inactive = true


func _on_fire_emitted(burn_parameters : BurnParameters) -> void:
	# Distance check.
	var destination_pos : Vector2 = global_position
	if burn_parameters.source_pos.distance_to(destination_pos) > burn_parameters.ignition_range + _catch_fire_range:
		return
	
	# Already burning target hit by fire ball?
	if _is_burning and burn_parameters.is_player_induced and _burn_time >= _INCINERATION_GRACE_TIME:
		_is_incinerated = true
		return

	# Burn start check.
	if burn_parameters.source_burn_time >= _catch_burn_time or burn_parameters.force_immediate:
		_is_burning = true

	# Flee direction is in the opposite direction from the fire source.
	_is_player_induced = burn_parameters.is_player_induced
	if burn_parameters.source_pos.x > destination_pos.x:
		_hor_burn_flee_direction = Types.Direction.LEFT
	else:
		_hor_burn_flee_direction = Types.Direction.RIGHT
	
	if burn_parameters.source_pos.y > destination_pos.y:
		_ver_burn_flee_direction = Types.Direction.UP
	else:
		_ver_burn_flee_direction = Types.Direction.DOWN
