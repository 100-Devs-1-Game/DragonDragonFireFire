class_name EnemyWalker
extends Enemy

enum State
{
	WALK,
	FALL_BEGIN,
	FALLING,
	DROPPED,
	DYING,
}

const _SPEED : float = 20.0

@export var starting_direction : Types.Direction = Types.Direction.RIGHT

var _cur_state : State = State.WALK
var _cur_dir : Types.Direction = Types.Direction.RIGHT

var _fall_begin_time : float = 0.0
var _drop_time : float = 0.0

var _burned_previously : bool = false

@onready var _burn_component : BurnComponent = $BurnComponent
@onready var _burn_visuals : Node2D = $Visuals/BurnVisuals

@onready var _sprite : AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var _ground_shape_cast : ShapeCast2D = $GroundShapeCast

@onready var _head_check_component : HeadCheckComponent = $HeadCheckComponent

@onready var _edge_shape_cast_left : ShapeCast2D = $EdgeShapeCastLeft
@onready var _edge_shape_cast_right : ShapeCast2D = $EdgeShapeCastRight


func _ready() -> void:
	super._ready()
	_burn_visuals.visible = false

	_cur_dir = starting_direction


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

	match _cur_state:
		State.WALK:
			if not object_beneath:
				_cur_state = State.FALL_BEGIN
				_fall_begin_time = 0.0
			else:
				_check_if_flees_from_burning()

				velocity.x = _SPEED if _cur_dir == Types.Direction.RIGHT else -_SPEED
				if _burn_component.is_burning():
					velocity.x *= _BURNING_MODIFIER
				
				velocity.y = 0
				move_and_slide()

				# Turn around at walls.
				if is_on_wall():
					_cur_dir = Types.Direction.LEFT if _cur_dir == Types.Direction.RIGHT else Types.Direction.RIGHT
				
				# Turn around at edges, but only if not on fire.
				_edge_shape_cast_left.force_shapecast_update()
				_edge_shape_cast_right.force_shapecast_update()
				var burning : bool = _burn_component.is_burning()
				if not _edge_shape_cast_left.is_colliding() and _cur_dir == Types.Direction.LEFT and not burning:
					_cur_dir = Types.Direction.RIGHT
				elif not _edge_shape_cast_right.is_colliding() and _cur_dir == Types.Direction.RIGHT and not burning:
					_cur_dir = Types.Direction.LEFT

		
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
			_drop_time += delta if not _burn_component.is_burning() else _BURNING_MODIFIER * delta
			if not object_beneath:
				_cur_state = State.FALL_BEGIN
				_fall_begin_time = 0.0
			else:
				velocity = Vector2(0, 0)
				if _drop_time >= _DROP_TIME_THRESHOLD:
					_cur_state = State.WALK
		
		State.DYING:
			velocity = Vector2(0, 0)
			_death_time_elapsed += delta
			_update_death_visuals()
			if _death_time_elapsed >= _DEATH_SEQUENCE_TIME:
				die()


func _check_if_flees_from_burning() -> void:
	if not _burned_previously and _burn_component.is_burning():
		_burned_previously = true
		if _burn_component.does_scare_enemies():
			_cur_dir = _burn_component.get_hor_burn_flee_direction()


func _handle_animation() -> void:
	if GameState.is_halted():
		_sprite.pause()
		return
	
	_visuals.scale.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0

	_sprite.speed_scale = 1.0 if not _burn_component.is_burning() else _BURNING_MODIFIER
	match _cur_state:
		State.WALK:
			if _burn_component.is_burning():
				_sprite.play("walking_hurt")
			else:
				_sprite.play("walking")
		State.FALL_BEGIN:
			_sprite.play("falling")
		State.FALLING:
			_sprite.play("falling")
		State.DROPPED:
			_sprite.play("standing")
