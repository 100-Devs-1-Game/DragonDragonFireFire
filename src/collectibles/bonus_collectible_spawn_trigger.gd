class_name BonusCollectibleSpawnTrigger
extends Node2D

var _has_triggered : bool = false


func _process(_delta : float) -> void:
	if GameState.is_halted():
		return
	
	if _has_triggered:
		return

	Signals.bonus_collectible_spawn_triggered.emit()
	_has_triggered = true
