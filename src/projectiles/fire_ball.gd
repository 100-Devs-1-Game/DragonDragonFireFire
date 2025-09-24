class_name FireBall
extends Area2D

const _FIRE_BALL_EXPLOSION_SCENE : PackedScene = preload("res://effects/fire_ball_explosion.tscn")

const _SPEED : float = 150.0
const _IGNITION_RANGE : float = 12.0

var _motion_vector : Vector2 = Vector2(_SPEED, 0)


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		return
		
	position += _motion_vector * delta
	_check_bounds()


func set_left() -> void:
	_motion_vector = Vector2(-_SPEED, 0)


func set_right() -> void:
	_motion_vector = Vector2(_SPEED, 0)


func set_up() -> void:
	_motion_vector = Vector2(0, -_SPEED)


func _check_bounds() -> void:
	var oob_x : bool = position.x < 0 or position.x > Constants.ARENA_WIDTH
	var oob_y : bool = position.y < 0 or position.y > Constants.ARENA_HEIGHT
	if oob_x or oob_y:
		queue_free()


func _make_burn_parameters() -> BurnParameters:
	var params : BurnParameters = BurnParameters.new()
	params.source_pos = global_position
	params.source_burn_time = 0.0
	params.ignition_range = _IGNITION_RANGE
	params.force_immediate = true
	params.scares_enemies = true
	return params


func _on_body_entered(_body):
	var burn_params : BurnParameters = _make_burn_parameters()
	Signals.fire_emitted.emit(burn_params)

	var explosion : FireBallExplosion = _FIRE_BALL_EXPLOSION_SCENE.instantiate() as FireBallExplosion
	explosion.global_position = global_position
	get_parent().add_child(explosion)

	queue_free()
