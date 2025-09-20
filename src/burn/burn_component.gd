class_name BurnComponent
extends Node2D

var _is_burning : bool = false
var _burn_time : float = 0.0
var _time_since_last_tick : float = 0.0

@export var _ignition_range : float = 0.0
@export var _force_immediate : bool = false

@export var _catch_fire_range : float = 0.0
@export var _catch_burn_time : float = 0.0


func _ready() -> void:
	Signals.fire_emitted.connect(_on_fire_emitted)


func _process(delta : float) -> void:
	if not _is_burning:
		return
	
	_burn_time += delta
	_time_since_last_tick += delta
	if _time_since_last_tick >= Constants.FIRE_TICK_TIME:
		var burn_params : BurnParameters = _make_burn_parameters()
		Signals.fire_emitted.emit(burn_params)
		_time_since_last_tick = 0.0


func is_burning() -> bool:
	return _is_burning


func get_burn_time() -> float:
	return _burn_time


func _make_burn_parameters() -> BurnParameters:
	var params : BurnParameters = BurnParameters.new()
	params.source_pos = global_position
	params.source_burn_time = _burn_time
	params.ignition_range = _ignition_range
	params.force_immediate = _force_immediate
	return params


func _on_fire_emitted(burn_parameters : BurnParameters) -> void:
	if _is_burning:
		return
	
	var destination_pos : Vector2 = global_position
	if burn_parameters.source_pos.distance_to(destination_pos) > burn_parameters.ignition_range + _catch_fire_range:
		return
	
	if burn_parameters.source_burn_time >= _catch_burn_time or burn_parameters.force_immediate:
		_is_burning = true
