class_name Stage
extends ColorRect

const _COLLECTIBLE_SPAWNER_SCENE : PackedScene = preload("res://collectibles/collectible_spawner.tscn")
const _SCORE_INDICATOR_SCENE : PackedScene = preload("res://effects/score_indicator.tscn")

@onready var _player : Player = $Player


func _ready() -> void:
	# Enable clipping to ensure safety tiles above and below stage are never visible during transition.
	size = Vector2(Constants.ARENA_WIDTH, Constants.ARENA_HEIGHT)
	clip_contents = true


# Performs the initial stage setup steps that are the same each time a stage is entered.
func do_setup() -> void:
	# Create the collectible spawner.
	var collectible_spawner : CollectibleSpawner = _COLLECTIBLE_SPAWNER_SCENE.instantiate() as CollectibleSpawner
	add_child(collectible_spawner)


func get_player() -> Player:
	return _player


func grant_completion_bonus() -> void:
	var granted_score : int = Constants.STAGE_COMPLETION_BONUS_SCORE * GameState.current_stage
	
	var score_indicator : ScoreIndicator = _SCORE_INDICATOR_SCENE.instantiate() as ScoreIndicator
	add_child(score_indicator)
	score_indicator.set_spawn_position(Vector2(Constants.ARENA_WIDTH * 0.5, Constants.ARENA_HEIGHT * 0.4))
	score_indicator.set_score(granted_score)
	score_indicator.set_description_text("COMPLETION BONUS!")
	score_indicator.increase_duration()

	GameState.score += granted_score
