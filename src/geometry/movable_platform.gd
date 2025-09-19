class_name MovablePlatform
extends FallableGeometry


func _physics_process(delta : float) -> void:
	_handle_fall_logic(delta)
