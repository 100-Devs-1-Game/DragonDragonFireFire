class_name EnemySweeper
extends Enemy

enum State
{
	MOVING,
	DYING,
}

const _SPEED : float = 60.0

@export var starting_direction : Types.Direction = Types.Direction.RIGHT

var _cur_state : State = State.MOVING
var _cur_dir : Types.Direction = starting_direction

var _burned_previously : bool = false

@onready var _burn_component : BurnComponent = $BurnComponent
@onready var _burn_visuals : Node2D = $Visuals/BurnVisuals

@onready var _sprite : AnimatedSprite2D = $Visuals/AnimatedSprite2D

@onready var _head_check_component : HeadCheckComponent = $HeadCheckComponent

@onready var _surroundings_shape_cast_top : ShapeCast2D = $SurroundingsCheckers/ShapeCastTop
@onready var _surroundings_shape_cast_bottom : ShapeCast2D = $SurroundingsCheckers/ShapeCastBottom
@onready var _surroundings_shape_cast_left : ShapeCast2D = $SurroundingsCheckers/ShapeCastLeft
@onready var _surroundings_shape_cast_right : ShapeCast2D = $SurroundingsCheckers/ShapeCastRight
@onready var _surroundings_shape_cast_top_left : ShapeCast2D = $SurroundingsCheckers/ShapeCastTL
@onready var _surroundings_shape_cast_top_right : ShapeCast2D = $SurroundingsCheckers/ShapeCastTR
@onready var _surroundings_shape_cast_bottom_right : ShapeCast2D = $SurroundingsCheckers/ShapeCastBR
@onready var _surroundings_shape_cast_bottom_left : ShapeCast2D = $SurroundingsCheckers/ShapeCastBL


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

	_perform_first_burn_check()

	match _cur_state:
		State.MOVING:
			_move_towards_direction(delta)
			_check_for_direction_change()

		State.DYING:
			collision_layer = 0 # Stop being an interactible enemy, in particular don't kill player anymore.
			velocity = Vector2(0, 0)
			_death_time_elapsed += delta
			_update_death_visuals()
			if _death_time_elapsed >= _DEATH_SEQUENCE_TIME:
				die()


func _perform_first_burn_check() -> void:
	# Just caught fire?
	if not _burned_previously and _burn_component.is_burning():
		SoundPool.play_sound(SoundPool.SOUND_ENEMY_SET_ON_FIRE)
		_burned_previously = true
		if _burn_component.does_scare_enemies():
			var hor_flee_direction : Types.Direction = _burn_component.get_hor_burn_flee_direction()
			var ver_flee_direction : Types.Direction = _burn_component.get_ver_burn_flee_direction()
			# When currently moving left/right: Flee horizontally.
			if _cur_dir == Types.Direction.LEFT or _cur_dir == Types.Direction.RIGHT:
				_cur_dir = hor_flee_direction
			# When currently moving up/down: Flee vertically.
			else:
				_cur_dir = ver_flee_direction


func _handle_animation() -> void:
	if GameState.is_halted():
		_sprite.pause()
		return

	match _cur_state:
		State.MOVING:
			if _burn_component.is_burning():
				_sprite.play("burning")
			else:
				_sprite.play("moving")


func _move_towards_direction(_delta : float) -> void:
	var motion_vector : Vector2 = Vector2.ZERO
	match _cur_dir:
		Types.Direction.UP:
			motion_vector = Vector2(0, -1)
		Types.Direction.DOWN:
			motion_vector = Vector2(0, 1)
		Types.Direction.LEFT:
			motion_vector = Vector2(-1, 0)
		Types.Direction.RIGHT:
			motion_vector = Vector2(1, 0)
	
	velocity = motion_vector * _SPEED
	if _burn_component.is_burning():
		velocity *= _BURNING_MODIFIER

	move_and_slide()


func _check_for_direction_change() -> void:
	_update_shape_casts()

	match _cur_dir:
		Types.Direction.RIGHT:
			_cur_dir = _assess_situation(Types.Direction.RIGHT, Types.Direction.LEFT, Types.Direction.UP,
					Types.Direction.DOWN, _surroundings_shape_cast_right, _surroundings_shape_cast_top,
					_surroundings_shape_cast_bottom, _surroundings_shape_cast_top_left,
					_surroundings_shape_cast_bottom_left)
		Types.Direction.LEFT:
			_cur_dir = _assess_situation(Types.Direction.LEFT, Types.Direction.RIGHT, Types.Direction.DOWN,
					Types.Direction.UP, _surroundings_shape_cast_left, _surroundings_shape_cast_bottom,
					_surroundings_shape_cast_top, _surroundings_shape_cast_bottom_right,
					_surroundings_shape_cast_top_right)
		Types.Direction.UP:
			_cur_dir = _assess_situation(Types.Direction.UP, Types.Direction.DOWN, Types.Direction.LEFT,
					Types.Direction.RIGHT, _surroundings_shape_cast_top, _surroundings_shape_cast_left,
					_surroundings_shape_cast_right, _surroundings_shape_cast_bottom_left,
					_surroundings_shape_cast_bottom_right)
		Types.Direction.DOWN:
			_cur_dir = _assess_situation(Types.Direction.DOWN, Types.Direction.UP, Types.Direction.RIGHT,
					Types.Direction.LEFT, _surroundings_shape_cast_bottom, _surroundings_shape_cast_right,
					_surroundings_shape_cast_left, _surroundings_shape_cast_top_right,
					_surroundings_shape_cast_top_left)


func _assess_situation(dir_forward : Types.Direction, dir_backward : Types.Direction, dir_left : Types.Direction,
		dir_right : Types.Direction, sc_forward : ShapeCast2D, sc_left : ShapeCast2D, sc_right : ShapeCast2D,
		sc_corner_back_left : ShapeCast2D, sc_corner_back_right : ShapeCast2D) -> Types.Direction:
	
	# Colliding? We've hit a wall in front of us, turn into free direction.
	if sc_forward.is_colliding():
		if sc_left.is_colliding() and not sc_right.is_colliding():
			return dir_right
		elif sc_right.is_colliding() and not sc_left.is_colliding():
			return dir_left
		elif not sc_left.is_colliding() and not sc_right.is_colliding():
			# Both sides free, move ccw.
			return dir_left
		else:
			# Both sides blocked, turn around.
			return dir_backward
	
	# Lost wall contact?
	if not sc_left.is_colliding() and not sc_right.is_colliding():
		# We might have a corner. Which way does it go?
		if sc_corner_back_left.is_colliding():
			return dir_left
		elif sc_corner_back_right.is_colliding():
			return dir_right
		else:
			# Fully lost attachment, just move forward and hope for the best.
			return dir_forward

	# In any other case, continue moving.
	return dir_forward


func _update_shape_casts() -> void:
	_surroundings_shape_cast_top.force_shapecast_update()
	_surroundings_shape_cast_bottom.force_shapecast_update()
	_surroundings_shape_cast_left.force_shapecast_update()
	_surroundings_shape_cast_right.force_shapecast_update()
	_surroundings_shape_cast_top_left.force_shapecast_update()
	_surroundings_shape_cast_top_right.force_shapecast_update()
	_surroundings_shape_cast_bottom_right.force_shapecast_update()
	_surroundings_shape_cast_bottom_left.force_shapecast_update()
