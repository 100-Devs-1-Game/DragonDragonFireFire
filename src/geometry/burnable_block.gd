class_name BurnableBlock
extends FallableGeometry

const _BURN_DESTROY_TIME : float = 3.0

@onready var burn_component : BurnComponent = $BurnComponent
@onready var burn_sprite : AnimatedSprite2D = $Visuals/BurnSprite


func _process(_delta : float) -> void:
	burn_sprite.visible = burn_component.is_burning()

	if burn_component.is_burning() and burn_component.get_burn_time() >= _BURN_DESTROY_TIME:
		queue_free()


func _physics_process(delta : float) -> void:
	_handle_fall_logic(delta)
