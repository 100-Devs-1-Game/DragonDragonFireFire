class_name OKLabel
extends Label

var _selected : bool = false

@onready var _selection_visuals : Control = $SelectionVisuals


func _process(_delta : float) -> void:
	_selection_visuals.visible = _selected


func set_selected(selected : bool) -> void:
	_selected = selected
