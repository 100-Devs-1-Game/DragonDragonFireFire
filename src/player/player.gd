class_name Player
extends CharacterBody2D

enum State
{
	UNDEFINED,
	MOVE,
	DEAD,
}

const _FIRE_BALL_SCENE : PackedScene = preload("res://projectiles/fire_ball.tscn")
const _FIRE_BALL_OFFSET_LEFT : Vector2 = Vector2(-8.0, -8.0)
const _FIRE_BALL_OFFSET_RIGHT : Vector2 = Vector2(8.0, -8.0)
const _FIRE_BALL_OFFSET_UP_LEFT : Vector2 = Vector2(-3.0, -16.0)
const _FIRE_BALL_OFFSET_UP_RIGHT : Vector2 = Vector2(3.0, -16.0)
const _FIRE_BALL_CADENCE : float = (1.0 / 5.5) # 5.5 per second

const _SPEED = 80.0
const _JUMP_VELOCITY = -166.0
const _MAX_FALL_SPEED = 130.0

const _JUMP_BUFFER_TIME : float = 0.1
const _FIRE_BALL_BUFFER_TIME : float = 0.1
const _COYOTE_TIME : float = 0.075

const _INVINCIBILITY_TIME : float = 2.0
const _INVINCIBILITY_FLASH_SPEED : float = 20.0

const _FIRE_SPIT_ANIMATION_TIME : float = 0.15

var _cur_state : State = State.MOVE
var _cur_dir : Types.Direction = Types.Direction.RIGHT
var _touched_by_enemy : bool = false

var _has_invincibility_frames : bool = false
var _invincibility_frames : float = 0.0

var _jump_buffer_timer : float = _JUMP_BUFFER_TIME + 0.01 # Time since jump action requested
var _fire_ball_buffer_timer : float = _FIRE_BALL_BUFFER_TIME + 0.01 # Time since fire ball action requested

var _time_since_last_ground_contact : float = 0.0
var _time_since_last_fire_spit : float = _FIRE_SPIT_ANIMATION_TIME + 0.01 # Allow immediate fire at start.

var _looking_up : bool = false

@onready var _visuals : Node2D = $Visuals
@onready var _sprite_head : AnimatedSprite2D = $Visuals/AnimatedSprite2DHead
@onready var _sprite_body : AnimatedSprite2D = $Visuals/AnimatedSprite2DBody
@onready var _head_check_component : HeadCheckComponent = $HeadCheckComponent
@onready var _one_way_platform_detector : ShapeCast2D = %OneWayPlatformDetector


func _ready() -> void:
	_sprite_head.play("normal")
	_sprite_body.play("idle")


func _process(delta : float) -> void:
	# Buffered inputs are handled independent from pause state
	_handle_buffered_inputs(delta)


func _handle_buffered_inputs(delta : float) -> void:
	_jump_buffer_timer += delta
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = 0.0

	_fire_ball_buffer_timer += delta
	if Input.is_action_just_pressed("fire"):
		_fire_ball_buffer_timer = 0.0


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		_update_animation() # Update animation regardless.
		return

	if _has_invincibility_frames:
		_invincibility_frames -= delta
		if _invincibility_frames <= 0.0:
			_has_invincibility_frames = false
	
	_time_since_last_fire_spit += delta

	_update_invincibility_visuals()
	
	match _cur_state:
		State.MOVE:
			_physics_process_move(delta)
		State.DEAD:
			_physics_process_dead(delta)
		_:
			pass
	
	_update_animation()
	
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

	if is_on_floor():
		_time_since_last_ground_contact = 0.0
	else:
		_time_since_last_ground_contact += delta

	# Handle jump.
	var down_pressed : bool = Input.is_action_pressed("down")
	_one_way_platform_detector.force_shapecast_update()

	var jump_buffered : bool = _jump_buffer_timer <= _JUMP_BUFFER_TIME
	if jump_buffered and _time_since_last_ground_contact <= _COYOTE_TIME:
		_jump_buffer_timer = _JUMP_BUFFER_TIME + 0.01 # Consume buffered jump.
		if down_pressed and _one_way_platform_detector.is_colliding():
			# Drop down through one-way platform.
			position.y += 1.0
		else:
			velocity.y = _JUMP_VELOCITY
			_time_since_last_ground_contact = _COYOTE_TIME + 0.01 # Consume coyote time.
			SoundPool.play_sound(SoundPool.SOUND_PLAYER_JUMP)

	var fire_ball_shot_buffered : bool = _fire_ball_buffer_timer <= _FIRE_BALL_BUFFER_TIME
	if fire_ball_shot_buffered and _time_since_last_fire_spit >= _FIRE_BALL_CADENCE:
		_fire_ball_buffer_timer = _FIRE_BALL_BUFFER_TIME + 0.01 # Consume buffered fire ball shot.
		_shoot_fire_ball()
	
	# Handle looking up.
	_looking_up = Input.is_action_pressed("up")

	_handle_direction_actions()
	
	if velocity.y > _MAX_FALL_SPEED:
		velocity.y = _MAX_FALL_SPEED
	move_and_slide()


func _physics_process_dead(_delta : float) -> void:
	pass


func grant_invincibility() -> void:
	_has_invincibility_frames = true
	_invincibility_frames = _INVINCIBILITY_TIME


func _update_invincibility_visuals() -> void:
	if _has_invincibility_frames:
		_visuals.modulate.a = 1.0 if int(_invincibility_frames * _INVINCIBILITY_FLASH_SPEED) % 2 == 0 else 0.5
	else:
		_visuals.modulate.a = 1.0


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

	if _looking_up:
		fire_ball.set_up()
		if _cur_dir == Types.Direction.LEFT:
			fire_ball.global_position = global_position + _FIRE_BALL_OFFSET_UP_LEFT
		else:
			fire_ball.global_position = global_position + _FIRE_BALL_OFFSET_UP_RIGHT
	else:
		if _cur_dir == Types.Direction.LEFT:
			fire_ball.set_left()
			fire_ball.global_position = global_position + _FIRE_BALL_OFFSET_LEFT
		else:
			fire_ball.set_right()
			fire_ball.global_position = global_position + _FIRE_BALL_OFFSET_RIGHT

	_time_since_last_fire_spit = 0.0
	SoundPool.play_sound(SoundPool.SOUND_FIRE_SHOT)


func _handle_death() -> void:
	Signals.player_died.emit()
	SoundPool.play_sound(SoundPool.SOUND_PLAYER_HURT)
	_cur_state = State.DEAD


func _update_animation() -> void:
	if GameState.is_halted():
		_sprite_head.pause()
		_sprite_body.pause()
		return
	
	_visuals.scale.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0

	# Body animations.
	match _cur_state:
		State.UNDEFINED:
			assert(false)
			_sprite_body.play("idle")
		State.MOVE:
			if not is_on_floor():
				if velocity.y < 0.0:
					_sprite_body.play("jump_up")
				else:
					_sprite_body.play("jump_down")
			elif abs(velocity.x) > 0.1:
				_sprite_body.play("walk")
			else:
				_sprite_body.play("idle")

		State.DEAD:
			_sprite_body.play("hurt")

	# Head animations.
	if _cur_state == State.MOVE:
		if _time_since_last_fire_spit < _FIRE_SPIT_ANIMATION_TIME:
			if _looking_up:
				if not is_on_floor() and velocity.y < 0.0:
					_sprite_head.play("jump_fire_up") # Fire&Jump + Looking up
				else:
					_sprite_head.play("fire_up") # Fire + Looking up
			else:
				if not is_on_floor() and velocity.y < 0.0:
					_sprite_head.play("jump_fire") # Fire&Jump
				else:
					_sprite_head.play("fire") # Fire
		else:
			if _looking_up:
				if not is_on_floor() and velocity.y < 0.0:
					_sprite_head.play("jump_up") # Jump + Looking up
				else:
					_sprite_head.play("normal_up") # Looking up
			else:
				if not is_on_floor() and velocity.y < 0.0:
					_sprite_head.play("jump") # Jump
				else:
					_sprite_head.play("normal") # -

	else:
		_sprite_head.play("invisible")



func _on_enemy_detection_hitbox_body_entered(_body):
	if _has_invincibility_frames:
		return
	
	_touched_by_enemy = true
