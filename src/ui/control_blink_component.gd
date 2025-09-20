class_name ControlBlinkComponent
extends Control

@export var blink_interval : float = 0.5

var _timer : float = 0.0


func _process(delta : float) -> void:
	assert(blink_interval > 0.0)

	if not get_parent():
		return
	
	assert(get_parent() is Control)

	_timer += delta
	if _timer >= blink_interval:
		_timer -= blink_interval
		get_parent().visible = not get_parent().visible
