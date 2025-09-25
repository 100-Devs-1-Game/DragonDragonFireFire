class_name MenuItemButton
extends Button

@onready var selection_arrow : TextureRect = $SelectionArrow


func _process(_delta : float) -> void:
	selection_arrow.visible = has_focus()


func _on_mouse_entered():
	grab_focus()
