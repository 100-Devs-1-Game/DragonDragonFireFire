class_name Enemy
extends CharacterBody2D

const _POOF_EFFECT_SCENE : PackedScene = preload("res://effects/poof_effect.tscn")
const _SCORE_INDICATOR_SCENE : PackedScene = preload("res://effects/score_indicator.tscn")

# General enemy falling properties.
const _FALL_TIME_THRESHOLD : float = 0.5
const _DROP_TIME_THRESHOLD : float = 1.0
const _GRAVITY_MODIFIER : float = 0.25
const _MAX_FALL_SPEED : float = 120.0

# General enemy burning properties.
const _BURNING_MODIFIER : float = 2.0
const _BURN_TIME_TO_KILL : float = 3.0

# Other constant properties.
const _DESPAWN_DISTANCE : float = 64.0

@export var score : int = 0

@onready var _visuals : Node2D = $Visuals


func die() -> void:
	var poof_effect : PoofEffect = _POOF_EFFECT_SCENE.instantiate() as PoofEffect
	get_parent().add_child(poof_effect)
	poof_effect.global_position = _visuals.global_position

	var score_indicator : ScoreIndicator = _SCORE_INDICATOR_SCENE.instantiate() as ScoreIndicator
	get_parent().add_child(score_indicator)
	score_indicator.set_spawn_position(_visuals.global_position)
	score_indicator.set_score(score)

	GameState.score += score

	queue_free()


func check_out_of_bounds_despawn() -> void:
	var oob_x_min : bool = global_position.x < -_DESPAWN_DISTANCE
	var oob_x_max : bool = global_position.x > Constants.ARENA_WIDTH + _DESPAWN_DISTANCE
	var oob_y_min : bool = global_position.y < -_DESPAWN_DISTANCE
	var oob_y_max : bool = global_position.y > Constants.ARENA_HEIGHT + _DESPAWN_DISTANCE

	if oob_x_min or oob_x_max or oob_y_min or oob_y_max:
		queue_free()
