# Class name intentionally omitted, intended to be used as Autoload.
extends Node

var cutscene : bool = false
var paused : bool = false

var score : int = 0
var time_left : float = float(Constants.PLAY_TIME)


func is_in_cutscene() -> bool:
	return cutscene


func is_paused() -> bool:
	return paused


func is_halted() -> bool:
	return cutscene or paused
