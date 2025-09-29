# Class name intentionally omitted, intended to be used as Autoload.
extends Node

class PlayerPos:
	var valid : bool = false
	var value : Vector2 = Vector2.ZERO


func get_player_global_position() -> PlayerPos:
	# Find nodes in group "player".
	var players := get_tree().get_nodes_in_group("player")

	var retval : PlayerPos = PlayerPos.new()
	if not players.size() == 1:
		retval.valid = false
		return retval

	retval.valid = true
	retval.value = players[0].global_position
	return retval
