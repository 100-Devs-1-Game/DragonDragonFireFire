class_name Collectible
extends Area2D

enum Type
{
	UNDEFINED,
	FRUIT,
}

enum FruitType
{
	MUSHROOM,
	MELON,
	BURGER,
	CAKE,
}

const _COLLECTIBLE_SIZE : Vector2 = Vector2(12, 12)

const _FRUIT_SCORES : Dictionary[FruitType, int] = {
	FruitType.MUSHROOM: 100,
	FruitType.MELON: 200,
	FruitType.BURGER: 400,
	FruitType.CAKE: 800,
}

const _SCORE_INDICATOR_SCENE : PackedScene = preload("res://effects/score_indicator.tscn")

const _TEXTURE_MUSHROOM : Texture2D = preload("res://assets/collectibles/mushroom.png")
const _TEXTURE_MELON : Texture2D = preload("res://assets/collectibles/melon.png")
const _TEXTURE_BURGER : Texture2D = preload("res://assets/collectibles/burger.png")
const _TEXTURE_CAKE : Texture2D = preload("res://assets/collectibles/cake.png")

const _FRUIT_TEXTURE_DICT : Dictionary[FruitType, Texture2D] = {
	FruitType.MUSHROOM: _TEXTURE_MUSHROOM,
	FruitType.MELON: _TEXTURE_MELON,
	FruitType.BURGER: _TEXTURE_BURGER,
	FruitType.CAKE: _TEXTURE_CAKE,
}

var _is_active : bool = false
var _collectible_type: Type = Type.FRUIT
var _fruit_type : FruitType = FruitType.MUSHROOM

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _shape_cast_anything : ShapeCast2D = $ShapeCastAnything
@onready var _shape_cast_geometry : ShapeCast2D = $ShapeCastGeometry
@onready var _shape_cast_object_range : ShapeCast2D = $ShapeCastObjectRange
@onready var _shape_cast_valid_ground_left : ShapeCast2D = $ShapeCastValidGroundLeft
@onready var _shape_cast_valid_ground_right : ShapeCast2D = $ShapeCastValidGroundRight


func _ready() -> void:
	visible = false


func make_fruit() -> void:
	_collectible_type = Type.FRUIT
	_fruit_type = randi() % FruitType.size() as FruitType

	_sprite.texture = _FRUIT_TEXTURE_DICT[_fruit_type]
	assert(_sprite.texture.get_size() == _COLLECTIBLE_SIZE)

	_is_active = true
	visible = true


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
	
	queue_free()


func _perform_pickup_logic_fruit() -> void:
	var score = _FRUIT_SCORES[_fruit_type]

	var score_indicator : ScoreIndicator = _SCORE_INDICATOR_SCENE.instantiate() as ScoreIndicator
	get_parent().add_child(score_indicator)
	score_indicator.set_spawn_position(_sprite.global_position)
	score_indicator.set_score(score)

	GameState.score += score


func _on_body_entered(_body):
	if not _is_active:
		return
	
	_perform_pickup_logic()
