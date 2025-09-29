class_name ShooterProjectile
extends CharacterBody2D

const _DESPAWN_DISTANCE : float = 64.0
const _SPEED = 50.0

var _motion_vector : Vector2 = Vector2.ZERO


func _physics_process(_delta : float) -> void:
	if GameState.is_halted():
		return
	
	velocity = _motion_vector * _SPEED
	move_and_slide()

	_despawn_if_out_of_bounds()


func set_motion_vector(vec : Vector2) -> void:
	_motion_vector = vec.normalized()


func _despawn_if_out_of_bounds() -> void:
	var oob_x_min : bool = global_position.x < -_DESPAWN_DISTANCE
	var oob_x_max : bool = global_position.x > Constants.ARENA_WIDTH + _DESPAWN_DISTANCE
	var oob_y_min : bool = global_position.y < -_DESPAWN_DISTANCE
	var oob_y_max : bool = global_position.y > Constants.ARENA_HEIGHT + _DESPAWN_DISTANCE

	if oob_x_min or oob_x_max or oob_y_min or oob_y_max:
		queue_free()
