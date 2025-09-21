class_name EnemyController
extends Node


func get_enemy_count() -> int:
	# Enemies are all nodes in group "enemies".
	return get_tree().get_nodes_in_group("enemies").size()
