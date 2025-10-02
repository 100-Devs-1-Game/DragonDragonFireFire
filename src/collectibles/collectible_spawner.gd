class_name CollectibleSpawner
extends Node2D

const _COLLECTIBLE_SCENE : PackedScene = preload("res://collectibles/collectible.tscn")

const _SPAWN_MIN_X : int = 0
const _SPAWN_MAX_X : int = Constants.ARENA_WIDTH
const _SPAWN_MIN_Y : int = 0
const _SPAWN_MAX_Y : int = Constants.ARENA_HEIGHT
const _SPAWN_STEP_SIZE : int = 8
const _SPAWN_STEP_OFFSET : int = 4

@warning_ignore("integer_division") # Intended.
const _NUM_SPAWN_STEPS_X : int = (_SPAWN_MAX_X - _SPAWN_MIN_X) / _SPAWN_STEP_SIZE
@warning_ignore("integer_division") # Intended.
const _NUM_SPAWN_STEPS_Y : int = (_SPAWN_MAX_Y - _SPAWN_MIN_Y) / _SPAWN_STEP_SIZE

const _NUM_SPAWN_TRIES : int = 32
const _NUM_MAX_DISTANCE_VERTICAL_PLACEMENT : int = 64

const _MIN_TIME_TO_NEXT_SPAWN : float = 4.0
const _MAX_TIME_TO_NEXT_SPAWN : float = 8.0

const _NUM_SPAWNS_BONUS : int = 20
const _TIME_TO_NEXT_SPAWN_BONUS : float = 0.05

var _time_to_next_spawn : float = 0.0
var _stop_spawning : bool = false

var _is_in_bonus_mode : bool = false
var _bonus_spawns_done : int = 0


func _ready() -> void:
	Signals.transition_to_next_stage_started.connect(_on_transition_to_next_stage_started)
	Signals.bonus_collectible_spawn_triggered.connect(_on_bonus_collectible_spawn_triggered)
	_set_time_to_next_spawn()


func _process(delta: float) -> void:
	if GameState.is_halted():
		return
	
	if _stop_spawning:
		return
	
	_time_to_next_spawn -= delta
	if _time_to_next_spawn <= 0.0:
		_try_spawn_collectible()
		_set_time_to_next_spawn()
		if _is_in_bonus_mode:
			_bonus_spawns_done += 1
	
	if _is_in_bonus_mode and _bonus_spawns_done >= _NUM_SPAWNS_BONUS:
		_stop_spawning = true


func _set_time_to_next_spawn() -> void:
	if _is_in_bonus_mode:
		_time_to_next_spawn = _TIME_TO_NEXT_SPAWN_BONUS
	else:
		_time_to_next_spawn = randf_range(_MIN_TIME_TO_NEXT_SPAWN, _MAX_TIME_TO_NEXT_SPAWN)


func _try_spawn_collectible() -> void:
	var collectible : Collectible = _COLLECTIBLE_SCENE.instantiate() as Collectible
	add_child(collectible)

	# In bonus mode, the collectibles can be close to others.
	if _is_in_bonus_mode:
		collectible.allow_close_to_other_collectibles()

	var position_found : bool = _find_spawn_position(collectible)
	if position_found:
		_create_collectible(collectible)
	else:
		# Failed to find a position, discard collectible.
		collectible.queue_free()


func _find_spawn_position(collectible: Collectible) -> bool:
	for i in _NUM_SPAWN_TRIES:
		# Logic: First, find a random grid position.
		var grid_x : int = randi() % _NUM_SPAWN_STEPS_X
		var grid_y : int = randi() % _NUM_SPAWN_STEPS_Y
		var pos_x : int = _SPAWN_MIN_X + grid_x * _SPAWN_STEP_SIZE + _SPAWN_STEP_OFFSET
		var pos_y : int = _SPAWN_MIN_Y + grid_y * _SPAWN_STEP_SIZE + _SPAWN_STEP_OFFSET
		var spawn_position : Vector2 = Vector2(pos_x, pos_y)

		# Then, check if the position is blocked by anything. If it is, we don't use it.
		collectible.global_position = spawn_position
		if collectible._is_touching_anything():
			continue
		
		# Now we know the position is free and we'd like to lower the collectible until it is on a platform.
		var initial_y_position : float = collectible.global_position.y
		for y in _NUM_MAX_DISTANCE_VERTICAL_PLACEMENT:
			var test_position : Vector2 = Vector2(collectible.global_position.x, initial_y_position + y)
			collectible.global_position = test_position

			# If we have hit geometry, use the position from one prior. We now have our final candidate position.
			if collectible._is_touching_geometry():
				collectible.global_position = test_position - Vector2(0, 1)

				# Is the ground actually valid, i.e. are we not hanging over some edge?
				if not collectible._is_on_valid_ground():
					break # Break sub-look and continue looking.

				# Finally, check any other object is too close to the spawn position. If they are, we don't use it.
				if collectible._is_object_too_close_to_spawn():
					break # Break sub-look and continue looking.
				
				# Valid position found!
				return true

	# If we reach here, we have failed to find a valid position.
	return false


func _create_collectible(collectible: Collectible) -> void:
	# Every third collectible is a clock, otherwise fruit. Except for bonus spawn, there 1 out of 3 would be too many
	# clocks so use fewer.
	var clock_modifier : int = 3 if not _is_in_bonus_mode else 8

	if GameState.collectibles_spawned % clock_modifier == 1:
		collectible.make_clock()
	else:
		collectible.make_fruit()

	GameState.collectibles_spawned += 1


func _on_transition_to_next_stage_started() -> void:
	# No longer spawn new collectibles once transitioning to next stage, it's frustrating.
	_stop_spawning = true


func _on_bonus_collectible_spawn_triggered() -> void:
	_is_in_bonus_mode = true
	_bonus_spawns_done = 0
	_time_to_next_spawn = 0.0 # Immediately spawn.
