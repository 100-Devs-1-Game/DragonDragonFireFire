class_name PoofEffect
extends AnimatedSprite2D

const _MAX_LIFETIME : float = 0.25

var _lifetime : float = 0.0


func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= _MAX_LIFETIME:
		queue_free()
