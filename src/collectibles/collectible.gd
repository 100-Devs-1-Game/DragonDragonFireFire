class_name Collectible
extends CharacterBody2D

enum Type
{
	UNDEFINED,
	FRUIT,
	CLOCK,
}

enum FruitType
{
	MUSHROOM,
	MELON,
	BURGER,
	CAKE,
}

const _COLLECTIBLE_PICKUP_BLING_SCENE : PackedScene = preload("res://effects/collectible_pickup_bling.tscn")

const _GRAVITY_MODIFIER : float = 0.6
const _ACTIVATION_VELOCITY_Y : float = -50.0

const _BLING_SHADER_SPEED : float = 3.0

const _COLLECTIBLE_LIFETIME : float = 9.0
const _COLLECTIBLE_LIFETIME_BLINK : float = 1.25
const _COLLECTIBLE_LIFETIME_BLINK_SPEED : float = 20.0

const _FRUIT_SCORES : Dictionary[FruitType, int] = {
	FruitType.MUSHROOM: 100,
	FruitType.MELON: 200,
	FruitType.BURGER: 400,
	FruitType.CAKE: 800,
}

const _CLOCK_SECONDS_BONUS : int = 5

const _SCORE_INDICATOR_SCENE : PackedScene = preload("res://effects/score_indicator.tscn")

const _SPRITE_FRAMES_MUSHROOM : SpriteFrames = preload("res://collectibles/sprite_frames_mushroom.tres")
const _SPRITE_FRAMES_MELON : SpriteFrames = preload("res://collectibles/sprite_frames_melon.tres")
const _SPRITE_FRAMES_BURGER : SpriteFrames = preload("res://collectibles/sprite_frames_burger.tres")
const _SPRITE_FRAMES_CAKE : SpriteFrames = preload("res://collectibles/sprite_frames_cake.tres")

const _FRUIT_SPRITE_FRAMES_DICT : Dictionary[FruitType, SpriteFrames] = {
	FruitType.MUSHROOM: _SPRITE_FRAMES_MUSHROOM,
	FruitType.MELON: _SPRITE_FRAMES_MELON,
	FruitType.BURGER: _SPRITE_FRAMES_BURGER,
	FruitType.CAKE: _SPRITE_FRAMES_CAKE,
}

const _CLOCK_SPRITE_FRAMES : SpriteFrames = preload("res://collectibles/sprite_frames_clock.tres")

var _is_active : bool = false
var _collectible_type: Type = Type.FRUIT
var _fruit_type : FruitType = FruitType.MUSHROOM
var _fixed_x_position : float = 0.0
var _bling_shader_progress : float = 0.0
var _lifetime : float = _COLLECTIBLE_LIFETIME

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shape_cast_anything : ShapeCast2D = $ShapeCastAnything
@onready var _shape_cast_geometry : ShapeCast2D = $ShapeCastGeometry
@onready var _shape_cast_object_range : ShapeCast2D = $ShapeCastObjectRange
@onready var _shape_cast_valid_ground_left : ShapeCast2D = $ShapeCastValidGroundLeft
@onready var _shape_cast_valid_ground_right : ShapeCast2D = $ShapeCastValidGroundRight
@onready var _stuck_inside_geometry_component : StuckInsideGeometryComponent = $StuckInsideGeometryComponent


func _ready() -> void:
	visible = false


func _process(delta : float) -> void:
	if GameState.is_halted():
		return
	
	if not _is_active:
		return

	_bling_shader_progress += _BLING_SHADER_SPEED * delta
	_sprite.material.set_shader_parameter("progress", _bling_shader_progress)
	if _bling_shader_progress > 1.0:
		_sprite.material.set_shader_parameter("is_active", false)
	
	_lifetime -= delta
	if _lifetime < _COLLECTIBLE_LIFETIME_BLINK:
		visible = int(_lifetime * _COLLECTIBLE_LIFETIME_BLINK_SPEED) % 2 == 0

	if _lifetime <= 0.0:
		queue_free()


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		return

	if not _is_active:
		return

	if _stuck_inside_geometry_component.has_been_stuck():
		# Stuck inside geometry, just despawn.
		queue_free()
		return

	# Apply gravity.
	velocity += get_gravity() * _GRAVITY_MODIFIER * delta
	velocity.x = 0.0
	move_and_slide()

	# Lock X position.
	global_position.x = _fixed_x_position

	
func make_fruit() -> void:
	_collectible_type = Type.FRUIT
	_fruit_type = randi() % FruitType.size() as FruitType

	_sprite.sprite_frames = _FRUIT_SPRITE_FRAMES_DICT[_fruit_type]

	_activate()


func make_clock() -> void:
	_collectible_type = Type.CLOCK
	_sprite.sprite_frames = _CLOCK_SPRITE_FRAMES

	_activate()


func _activate() -> void:
	_is_active = true
	visible = true
	_sprite.play("default")
	_fixed_x_position = global_position.x
	velocity.y = _ACTIVATION_VELOCITY_Y


func _is_touching_anything() -> bool:
	_shape_cast_anything.force_shapecast_update()
	return _shape_cast_anything.is_colliding()


func _is_touching_geometry() -> bool:
	_shape_cast_geometry.force_shapecast_update()
	return _shape_cast_geometry.is_colliding()


func _is_object_too_close_to_spawn() -> bool:
	# Is any object too close?
	_shape_cast_object_range.force_shapecast_update()
	return _shape_cast_object_range.is_colliding()


func _is_on_valid_ground() -> bool:
	_shape_cast_valid_ground_left.force_shapecast_update()
	_shape_cast_valid_ground_right.force_shapecast_update()
	return _shape_cast_valid_ground_left.is_colliding() and _shape_cast_valid_ground_right.is_colliding()


func _perform_pickup_logic() -> void:
	match _collectible_type:
		Type.FRUIT:
			_perform_pickup_logic_fruit()
		Type.CLOCK:
			_perform_pickup_logic_clock()

	queue_free()


func _perform_pickup_logic_fruit() -> void:
	var score = _FRUIT_SCORES[_fruit_type]

	var score_indicator : ScoreIndicator = _SCORE_INDICATOR_SCENE.instantiate() as ScoreIndicator
	get_parent().add_child(score_indicator)
	score_indicator.set_spawn_position(_sprite.global_position)
	score_indicator.set_score(score)

	GameState.score += score
	GameState.food_eaten += 1


func _perform_pickup_logic_clock() -> void:
	GameState.bonus_seconds += _CLOCK_SECONDS_BONUS


func _on_collectible_area_body_entered(_body):
	if not _is_active:
		return
	
	SoundPool.play_sound(SoundPool.SOUND_COLLECTIBLE_PICKED_UP)
	var bling : CollectiblePickupBling = _COLLECTIBLE_PICKUP_BLING_SCENE.instantiate() as CollectiblePickupBling
	get_parent().add_child(bling)
	bling.global_position = _sprite.global_position

	_perform_pickup_logic()
