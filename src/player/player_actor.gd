class_name PlayerActor
extends CharacterBody2D

enum AnimationOverrides
{
	NONE,
	CHEER,
}

const _FIRE_BALL_SCENE : PackedScene = preload("res://projectiles/fire_ball.tscn")

const _FIRE_BALL_OFFSET_LEFT : Vector2 = Vector2(-8.0, -8.0)
const _FIRE_BALL_OFFSET_RIGHT : Vector2 = Vector2(8.0, -8.0)

var _cur_direction : Types.Direction = Types.Direction.RIGHT
var _animation_override : AnimationOverrides = AnimationOverrides.NONE

@onready var _visuals : Node2D = $Visuals
@onready var _sprite_head : AnimatedSprite2D = $Visuals/AnimatedSprite2DHead
@onready var _sprite_body : AnimatedSprite2D = $Visuals/AnimatedSprite2DBody


func _physics_process(delta):
	_update_animation()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func play_end_screen_sequence() -> void:
	_sprite_head.play("normal")
	_sprite_body.play("walk")

	var animation_tween : Tween = get_tree().create_tween()
	animation_tween.tween_interval(0.5)
	animation_tween.tween_property(self, "velocity:x", 100.0, 0.0)
	animation_tween.tween_interval(1.05)
	animation_tween.tween_property(self, "velocity:x", 0.0, 0.0)
	animation_tween.tween_interval(0.2)
	animation_tween.tween_callback(SoundPool.play_sound.bind(SoundPool.SOUND_PLAYER_JUMP))
	animation_tween.tween_callback(_set_velocity_y.bind(-140.0))
	animation_tween.tween_interval(0.45)
	animation_tween.tween_callback(SoundPool.play_sound.bind(SoundPool.SOUND_FIRE_SHOT))
	animation_tween.tween_callback(_spawn_fire_ball)
	animation_tween.tween_interval(0.25)
	animation_tween.tween_callback(SoundPool.play_sound.bind(SoundPool.SOUND_FIRE_SHOT))
	animation_tween.tween_callback(_spawn_fire_ball)
	animation_tween.tween_interval(1.0)
	animation_tween.tween_callback(_set_animation_override.bind(AnimationOverrides.CHEER))


func _update_animation() -> void:
	_visuals.scale.x = 1.0 if _cur_direction == Types.Direction.RIGHT else -1.0

	if _animation_override == AnimationOverrides.CHEER:
		_sprite_body.play("cheer")
		_sprite_head.play("invisible")
		return
	
	var moving_horizontally : bool = abs(velocity.x) > 0.1
	var in_jump_up : bool = not is_on_floor() and velocity.y < 0.0
	var in_jump_down : bool = not is_on_floor() and velocity.y >= 0.0

	# Body animations.
	if in_jump_up:
		_sprite_body.play("jump_up")
	elif in_jump_down:
		_sprite_body.play("jump_down")
	elif moving_horizontally:
		_sprite_body.play("walk")
	else:
		_sprite_body.play("idle")

	# Head animations.
	if in_jump_up:
		_sprite_head.play("jump")
	elif in_jump_down:
		_sprite_head.play("normal")
	elif moving_horizontally:
		_sprite_head.play("normal")
	else:
		_sprite_head.play("normal")


func _set_velocity_y(new_velocity_y : float) -> void:
	velocity.y = new_velocity_y


func _set_direction(new_direction : Types.Direction) -> void:
	_cur_direction = new_direction


func _set_animation_override(new_override : AnimationOverrides) -> void:
	_animation_override = new_override


func _spawn_fire_ball() -> void:
	var fire_ball : FireBall = _FIRE_BALL_SCENE.instantiate()
	get_parent().add_child(fire_ball)

	fire_ball.z_index -= 1 # Appear behind stuff

	if _cur_direction == Types.Direction.LEFT:
		fire_ball.set_left()
		fire_ball.global_position = global_position + _FIRE_BALL_OFFSET_LEFT
	else:
		fire_ball.set_right()
		fire_ball.global_position = global_position + _FIRE_BALL_OFFSET_RIGHT
