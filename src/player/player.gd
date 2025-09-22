class_name Player
extends CharacterBody2D

enum State
{
	UNDEFINED,
	MOVE,
	DEAD,
}

const _FIRE_BALL_SCENE : PackedScene = preload("res://projectiles/fire_ball.tscn")
const _FIRE_BALL_OFFSET_X : float = 8.0
const _FIRE_BALL_OFFSET_Y : float = -8.0

const _SPEED = 80.0
const _JUMP_VELOCITY = -166.0
const _MAX_FALL_SPEED = 130.0

const _INVINCIBILITY_TIME : float = 2.0
const _INVINCIBILITY_FLASH_SPEED : float = 20.0

var _cur_state : State = State.MOVE
var _cur_dir : Types.Direction = Types.Direction.RIGHT
var _touched_by_enemy : bool = false

var has_invincibility_frames : bool = false
var invincibility_frames : float = 0.0

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _head_check_component : HeadCheckComponent = $HeadCheckComponent


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		return

	if has_invincibility_frames:
		invincibility_frames -= delta
		if invincibility_frames <= 0.0:
			has_invincibility_frames = false
	
	_update_invincibility_visuals()
	
	match _cur_state:
		State.MOVE:
			_physics_process_move(delta)
		State.DEAD:
			_physics_process_dead(delta)
		_:
			pass
	
	Teleport.handle_teleport(self)

	if _head_check_component.is_hit():
		_handle_death()


func _physics_process_move(delta : float) -> void:
	if _touched_by_enemy and not Debug.player_invincible:
		_handle_death()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = _JUMP_VELOCITY
	
	if Input.is_action_just_pressed("fire"):
		_shoot_fire_ball()

	_handle_direction_actions()
	
	if velocity.y > _MAX_FALL_SPEED:
		velocity.y = _MAX_FALL_SPEED
	move_and_slide()


func _physics_process_dead(_delta : float) -> void:
	pass


func grant_invincibility() -> void:
	has_invincibility_frames = true
	invincibility_frames = _INVINCIBILITY_TIME


func _update_invincibility_visuals() -> void:
	if has_invincibility_frames:
		_sprite.modulate.a = 1.0 if int(invincibility_frames * _INVINCIBILITY_FLASH_SPEED) % 2 == 0 else 0.5
	else:
		_sprite.modulate.a = 1.0


func _handle_direction_actions() -> void:
	var direction : float = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * _SPEED
		if abs(direction) < 0.01:
			pass
		elif direction < 0:
			_cur_dir = Types.Direction.LEFT
		else:
			_cur_dir = Types.Direction.RIGHT
	else:
		velocity.x = move_toward(velocity.x, 0, _SPEED)


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


func _handle_death() -> void:
	Signals.player_died.emit()
	_cur_state = State.DEAD


func _on_enemy_detection_hitbox_body_entered(_body):
	if has_invincibility_frames:
		return
	
	_touched_by_enemy = true
