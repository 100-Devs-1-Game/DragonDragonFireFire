extends CharacterBody2D

enum State
{
	UNDEFINED,
	MOVE,
}

const _FIRE_BALL_SCENE : PackedScene = preload("res://projectiles/fire_ball.tscn")
const _FIRE_BALL_OFFSET_X : float = 8.0
const _FIRE_BALL_OFFSET_Y : float = -8.0

const SPEED = 80.0
const JUMP_VELOCITY = -180.0

var _cur_state : State = State.MOVE
var _cur_dir : Types.Direction = Types.Direction.RIGHT


func _physics_process(delta : float) -> void:
	match _cur_state:
		State.MOVE:
			_physics_process_move(delta)
		_:
			pass


func _physics_process_move(delta : float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("fire"):
		_shoot_fire_ball()

	_handle_direction_actions()
	
	move_and_slide()


func _handle_direction_actions() -> void:
	var direction : float = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if abs(direction) < 0.01:
			pass
		elif direction < 0:
			_cur_dir = Types.Direction.LEFT
		else:
			_cur_dir = Types.Direction.RIGHT
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func _shoot_fire_ball() -> void:
	var fire_ball : FireBall = _FIRE_BALL_SCENE.instantiate()
	get_parent().add_child(fire_ball)

	var fire_ball_offset : Vector2 = Vector2(_FIRE_BALL_OFFSET_X, _FIRE_BALL_OFFSET_Y)
	if _cur_dir == Types.Direction.LEFT:
		fire_ball.set_left()
		fire_ball_offset.x *= -1
	else:
		fire_ball.set_right()

	fire_ball.global_position = global_position + fire_ball_offset
