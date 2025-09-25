class_name CreditsBorder
extends TextureRect

@export var associated_button : Button = null


func _ready() -> void:
	visible = false
	assert(associated_button)


func _process(_delta : float) -> void:
	if not associated_button:
		return

	visible = associated_button.has_focus()
