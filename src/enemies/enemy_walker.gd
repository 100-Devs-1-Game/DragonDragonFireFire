class_name EnemyWalker
extends Enemy

enum State
{
	WALK,
	FALL_BEGIN,
	FALLING,
	DROPPED,
}

const _SPEED : float = 20.0

var _cur_state : State = State.WALK
var _cur_dir : Types.Direction = Types.Direction.RIGHT

var _fall_begin_time : float = 0.0
var _drop_time : float = 0.0

@onready var burn_component : BurnComponent = $BurnComponent
@onready var burn_visuals : Node2D = $Visuals/BurnVisuals

@onready var visuals : Node2D = $Visuals
@onready var sprite : AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var ground_shape_cast : ShapeCast2D = $GroundShapeCast

@onready var _head_check_component : HeadCheckComponent = $HeadCheckComponent


func _ready() -> void:
	burn_visuals.visible = false


func _process(_delta : float) -> void:
	_handle_animation()
	
	burn_visuals.visible = burn_component.is_burning()
	if burn_component.is_burning() and burn_component.get_burn_time() >= _BURN_TIME_TO_KILL:
		queue_free() # TODO: Actual dying state.
	
	if _head_check_component.is_hit():
		queue_free() # TODO: Actual dying state.


func _physics_process(delta : float) -> void:
	ground_shape_cast.force_shapecast_update()
	var object_beneath : bool = ground_shape_cast.is_colliding()

	match _cur_state:
		State.WALK:
			if not object_beneath:
				_cur_state = State.FALL_BEGIN
				_fall_begin_time = 0.0
			else:
				velocity.x = _SPEED if _cur_dir == Types.Direction.RIGHT else -_SPEED
				if burn_component.is_burning():
					velocity.x *= _BURNING_MODIFIER
				
				velocity.y = 0
				move_and_slide()

				if is_on_wall():
					_cur_dir = Types.Direction.LEFT if _cur_dir == Types.Direction.RIGHT else Types.Direction.RIGHT
		
		State.FALL_BEGIN:
			_fall_begin_time += delta
			visuals.position.x = 1 if int(_fall_begin_time * Constants._FALL_SHAKE_SPEED_FACTOR) % 2 == 0 else 0
			if _fall_begin_time >= _FALL_TIME_THRESHOLD:
				_cur_state = State.FALLING
		
		State.FALLING:
			visuals.position.x = 0
			velocity.x = 0
			velocity += get_gravity() * _GRAVITY_MODIFIER * delta
			move_and_slide()
			if is_on_floor():
				_cur_state = State.DROPPED
				_drop_time = 0.0

		State.DROPPED:
			_drop_time += delta if not burn_component.is_burning() else _BURNING_MODIFIER * delta
			if not object_beneath:
				_cur_state = State.FALL_BEGIN
				_fall_begin_time = 0.0
			else:
				velocity = Vector2(0, 0)
				if _drop_time >= _DROP_TIME_THRESHOLD:
					_cur_state = State.WALK


func _handle_animation() -> void:
	visuals.scale.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0

	sprite.speed_scale = 1.0 if not burn_component.is_burning() else _BURNING_MODIFIER
	match _cur_state:
		State.WALK:
			sprite.play("walking")
		State.FALL_BEGIN:
			sprite.play("falling")
		State.FALLING:
			sprite.play("falling")
		State.DROPPED:
			sprite.play("standing")
