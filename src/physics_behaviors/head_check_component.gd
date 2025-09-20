class_name HeadCheckComponent
extends Area2D

@export var must_be_on_ground : bool = true

var _is_hit : bool = false

var _parent : CharacterBody2D = null
var _registered_bodies : Array[CharacterBody2D] = []


func _ready():
	assert(get_parent() is CharacterBody2D)
	_parent = get_parent() as CharacterBody2D


func _physics_process(_delta : float) -> void:
	if _check_if_hit():
		_is_hit = true


func is_hit() -> bool:
	return _is_hit


func _check_if_hit() -> bool:
	for body in _registered_bodies:
		if body == _parent:
			assert(false) # This should not actually happen when layer/mask is set as intended.
			continue
		
		if body.velocity.y < 0.01:
			continue

		if not _parent.is_on_floor() and must_be_on_ground:
			continue
		
		_is_hit = true
	
	return false


func _on_body_entered(body):
	_registered_bodies.append(body)


func _on_body_exited(body):
	_registered_bodies.erase(body)
