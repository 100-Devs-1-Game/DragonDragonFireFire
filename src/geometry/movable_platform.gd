class_name MovablePlatform
extends FallableGeometry


func _physics_process(delta : float) -> void:
	if GameState.is_halted():
		return
	
	_handle_fall_logic(delta)
