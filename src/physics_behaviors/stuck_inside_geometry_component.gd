class_name StuckInsideGeometryComponent
extends Area2D

# A small component that returns whether the parent CharacterBody2D got stuck inside geometry.

var _has_been_stuck : bool = false
var _parent : CharacterBody2D = null


func _ready():
	assert(get_parent() is CharacterBody2D)
	_parent = get_parent() as CharacterBody2D


func has_been_stuck() -> bool:
	return _has_been_stuck


func _on_body_entered(_body):
	_has_been_stuck = true
