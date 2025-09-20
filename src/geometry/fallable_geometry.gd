class_name FallableGeometry
extends CharacterBody2D

enum FallState
{
	ON_GROUND,
	FALL_BEGIN,
	DROPPING,
}

const _GRAVITY_MODIFIER : float = 0.25

var fall_state : FallState = FallState.ON_GROUND
var fall_begin_time : float = 0.0

@onready var ground_shape_cast : ShapeCast2D = $GroundShapeCast
@onready var visuals : Node2D = $Visuals


func _handle_fall_logic(delta : float) -> void:
	ground_shape_cast.force_shapecast_update()
	var object_beneath : bool = ground_shape_cast.is_colliding()

	match fall_state:
		FallState.ON_GROUND:
			if not object_beneath:
				fall_begin_time = 0.0
				fall_state = FallState.FALL_BEGIN
		FallState.FALL_BEGIN:
			fall_begin_time += delta
			visuals.position.x = 1 if int(fall_begin_time * Constants._FALL_SHAKE_SPEED_FACTOR) % 2 == 0 else 0
			if fall_begin_time >= Constants._FALL_TELEGRAPH_TIME:
				fall_state = FallState.DROPPING
		FallState.DROPPING:
			visuals.position.x = 0
			velocity += get_gravity() * _GRAVITY_MODIFIER * delta
			move_and_slide()
			if is_on_floor():
				fall_state = FallState.ON_GROUND
