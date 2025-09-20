class_name EnemyFlyer
extends Enemy

enum State
{
	FLYING,
}

const _SPEED : float = 30.0

var _cur_state : State = State.FLYING
var _cur_dir : Types.Direction = Types.Direction.RIGHT
var _cur_vertical_dir : Types.Direction = Types.Direction.DOWN

@onready var burn_component : BurnComponent = $BurnComponent
@onready var burn_visuals : Node2D = $Visuals/BurnVisuals

@onready var visuals : Node2D = $Visuals
@onready var sprite : AnimatedSprite2D = $Visuals/AnimatedSprite2D

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


func _physics_process(_delta : float) -> void:
	var cur_motion_vector : Vector2 = Vector2.ZERO
	cur_motion_vector.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0
	cur_motion_vector.y = 0.5 if _cur_vertical_dir == Types.Direction.DOWN else -0.5
	cur_motion_vector = cur_motion_vector.normalized()
	cur_motion_vector *= _SPEED

	if burn_component.is_burning():
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


func _handle_animation() -> void:
	visuals.scale.x = 1.0 if _cur_dir == Types.Direction.RIGHT else -1.0

	sprite.speed_scale = 1.0 if not burn_component.is_burning() else _BURNING_MODIFIER
	match _cur_state:
		State.FLYING:
			sprite.play("flying")
