class_name EnemyFlyer
extends Enemy

enum State
{
	FLYING,
	DYING,
}

const _SPEED : float = 50.0

var _cur_state : State = State.FLYING
var _cur_dir : Types.Direction = Types.Direction.RIGHT
var _cur_vertical_dir : Types.Direction = Types.Direction.DOWN

var _burned_previously : bool = false

@onready var _burn_component : BurnComponent = $BurnComponent
@onready var _burn_visuals : Node2D = $Visuals/BurnVisuals

@onready var _sprite : AnimatedSprite2D = $Visuals/AnimatedSprite2D

@onready var _head_check_component : HeadCheckComponent = $HeadCheckComponent


func _ready() -> void:
	_burn_visuals.visible = false


func _process(_delta : float) -> void:
	_handle_animation() # Handle animation even when paused as pausing the animation needs to be handled.

	if GameState.is_halted():
		return
	
	_burn_visuals.visible = _burn_component.is_burning()
	if _burn_component.is_burning() and _burn_component.get_burn_time() >= _BURN_TIME_TO_KILL:
		_cur_state = State.DYING

	if _head_check_component.is_hit():
		_cur_state = State.DYING

	check_out_of_bounds_despawn()
	Teleport.handle_teleport(self)


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		return

	_check_if_flees_from_burning()

	var cur_motion_vector : Vector2 = Vector2.ZERO
	cur_motion_vector.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0
	cur_motion_vector.y = 0.5 if _cur_vertical_dir == Types.Direction.DOWN else -0.5
	cur_motion_vector = cur_motion_vector.normalized()
	cur_motion_vector *= _SPEED

	if _burn_component.is_burning():
		cur_motion_vector *= _BURNING_MODIFIER

	match _cur_state:
		State.FLYING:
			velocity = cur_motion_vector
			move_and_slide()

			if is_on_wall():
				_cur_dir = Types.Direction.LEFT if _cur_dir == Types.Direction.RIGHT else Types.Direction.RIGHT
			if is_on_ceiling():
				_cur_vertical_dir = Types.Direction.DOWN
			elif is_on_floor():
				_cur_vertical_dir = Types.Direction.UP
		
		State.DYING:
			velocity = Vector2(0, 0)
			_death_time_elapsed += delta
			_update_death_visuals()
			if _death_time_elapsed >= _DEATH_SEQUENCE_TIME:
				die()


func _check_if_flees_from_burning() -> void:
	# Just caught fire?
	if not _burned_previously and _burn_component.is_burning():
		_burned_previously = true
		if _burn_component.does_scare_enemies():
			_cur_dir = _burn_component.get_burn_flee_direction()


func _handle_animation() -> void:
	if GameState.is_halted():
		_sprite.pause()
		return

	_visuals.scale.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0

	_sprite.speed_scale = 1.0 if not _burn_component.is_burning() else _BURNING_MODIFIER
	match _cur_state:
		State.FLYING:
			_sprite.play("flying")
