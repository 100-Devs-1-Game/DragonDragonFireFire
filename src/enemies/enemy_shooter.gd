class_name EnemyShooter
extends Enemy

enum State
{
	STANDING,
	FALL_BEGIN,
	FALLING,
	DROPPED,
	RUNNING,
	DYING,
}

const _PROJECTILE_SCENE : PackedScene = preload("res://projectiles/shooter_projectile.tscn")

const _RUN_SPEED : float = 30.0
const _DROP_FACTOR : float = 2.0
const _SHOOT_CADENCE : float = 1.5
const _PROJECTILE_OFFSET : Vector2 = Vector2(8.0, -4.0)

@export var starting_direction : Types.Direction = Types.Direction.RIGHT

var _cur_state : State = State.STANDING
var _cur_dir : Types.Direction = Types.Direction.RIGHT

var _fall_begin_time : float = 0.0
var _drop_time : float = 0.0
var _shoot_timer : float = 0.0
var _time_since_last_shot : float = _SHOOT_CADENCE + 0.01

var _burned_previously : bool = false

@onready var _burn_component : BurnComponent = $BurnComponent
@onready var _burn_visuals : Node2D = $Visuals/BurnVisuals

@onready var _sprite : AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var _ground_shape_cast : ShapeCast2D = $GroundShapeCast

@onready var _head_check_component : HeadCheckComponent = $HeadCheckComponent


func _ready() -> void:
	super._ready()
	_burn_visuals.visible = false

	_cur_dir = starting_direction
	_handle_animation() # Update initial animation.


func _process(_delta : float) -> void:
	_handle_animation() # Handle animation even when paused as pausing the animation needs to be handled.

	if GameState.is_halted():
		return
	
	_burn_visuals.visible = _burn_component.is_burning()
	if _burn_component.is_burning() and _burn_component.get_burn_time() >= _BURN_TIME_TO_KILL:
		_cur_state = State.DYING
	
	if _burn_component.is_incinerated():
		_cur_state = State.DYING
	
	if _head_check_component.is_hit():
		_cur_state = State.DYING

	check_out_of_bounds_despawn()
	Teleport.handle_teleport(self)


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		return

	_ground_shape_cast.force_shapecast_update()
	var object_beneath : bool = _ground_shape_cast.is_colliding()

	_perform_first_burn_check()

	match _cur_state:
		State.STANDING:
			# Don't look at the player if burning, we expect a state transition and running away soon.
			if not _burn_component.is_burning():
				_look_at_player()
			if not object_beneath:
				_cur_state = State.FALL_BEGIN
				_fall_begin_time = 0.0
			else:
				if _burn_component.is_burning():
					_cur_state = State.RUNNING
					return

				velocity = Vector2(0, 0)
				move_and_slide()

				_shoot_timer += delta
				_time_since_last_shot += delta
				if _shoot_timer >= _SHOOT_CADENCE:
					_time_since_last_shot = 0.0
					_shoot_timer = 0.0
					_handle_shot()


		State.RUNNING:
			assert(_burn_component.is_burning())
			if not object_beneath:
				_cur_state = State.FALL_BEGIN
				_fall_begin_time = 0.0
			else:
				velocity.x = _RUN_SPEED if _cur_dir == Types.Direction.RIGHT else -_RUN_SPEED
				if _burn_component.is_burning():
					velocity.x *= _BURNING_MODIFIER
				
				velocity.y = 0
				move_and_slide()

				# Turn around at walls.
				if is_on_wall():
					_cur_dir = Types.Direction.LEFT if _cur_dir == Types.Direction.RIGHT else Types.Direction.RIGHT
		
		State.FALL_BEGIN:
			_fall_begin_time += delta
			_visuals.position.x = 1 if int(_fall_begin_time * Constants.FALL_SHAKE_SPEED_FACTOR) % 2 == 0 else 0
			if _fall_begin_time >= _FALL_TIME_THRESHOLD:
				_cur_state = State.FALLING
		
		State.FALLING:
			_visuals.position.x = 0
			velocity.x = 0
			velocity += get_gravity() * _GRAVITY_MODIFIER * delta

			if velocity.y > _MAX_FALL_SPEED:
				velocity.y = _MAX_FALL_SPEED

			move_and_slide()
			if is_on_floor():
				_cur_state = State.DROPPED
				_drop_time = 0.0

		State.DROPPED:
			_drop_time += delta * _DROP_FACTOR
			if not object_beneath:
				_cur_state = State.FALL_BEGIN
				_fall_begin_time = 0.0
			else:
				velocity = Vector2(0, 0)
				if _drop_time >= _DROP_TIME_THRESHOLD:
					if _burn_component.is_burning():
						_cur_state = State.RUNNING
					else:
						_cur_state = State.STANDING
						_shoot_timer = 0.0
		
		State.DYING:
			collision_layer = 0 # Stop being an interactible enemy, in particular don't kill player anymore.
			velocity = Vector2(0, 0)
			_death_time_elapsed += delta
			_update_death_visuals()
			if _death_time_elapsed >= _DEATH_SEQUENCE_TIME:
				die()


func _handle_shot() -> void:
	var player_pos : PlayerUtils.PlayerPos = PlayerUtils.get_player_global_position()
	if not player_pos.valid:
		return

	var projectile : ShooterProjectile = _PROJECTILE_SCENE.instantiate() as ShooterProjectile
	get_parent().add_child(projectile)

	var proj_offs_right : Vector2 = _PROJECTILE_OFFSET
	var proj_offs_left : Vector2 = Vector2(-_PROJECTILE_OFFSET.x, _PROJECTILE_OFFSET.y)
	var proj_offs : Vector2 = proj_offs_right if _cur_dir == Types.Direction.RIGHT else proj_offs_left
	projectile.global_position = global_position + proj_offs

	var motion_vec : Vector2 = (player_pos.value - global_position).normalized()
	projectile.set_motion_vector(motion_vec)


func _look_at_player() -> void:
	var player_pos : PlayerUtils.PlayerPos = PlayerUtils.get_player_global_position()
	if not player_pos.valid:
		return
	
	if player_pos.value.x > global_position.x:
		_cur_dir = Types.Direction.RIGHT
	else:
		_cur_dir = Types.Direction.LEFT


func _perform_first_burn_check() -> void:
	if not _burned_previously and _burn_component.is_burning():
		SoundPool.play_sound(SoundPool.SOUND_ENEMY_SET_ON_FIRE)
		_burned_previously = true
		if _burn_component.does_scare_enemies():
			_cur_dir = _burn_component.get_hor_burn_flee_direction()


func _handle_animation() -> void:
	_visuals.scale.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0
	
	if GameState.is_halted():
		_sprite.pause()
		return

	match _cur_state:
		State.STANDING:
			if _time_since_last_shot < 0.2:
				_sprite.play("shooting")
			else:
				_sprite.play("standing")
		State.RUNNING:
			_sprite.play("running")
		State.FALL_BEGIN:
			_sprite.play("falling")
		State.FALLING:
			_sprite.play("falling")
		State.DROPPED:
			_sprite.play("standing")
