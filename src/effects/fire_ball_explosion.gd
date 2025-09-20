class_name FireBallExplosion
extends AnimatedSprite2D

const _MAX_LIFETIME : float = 0.2

var _lifetime : float = 0.0


func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= _MAX_LIFETIME:
		queue_free()
