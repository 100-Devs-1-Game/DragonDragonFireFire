class_name Initial
extends Label

const _INITIALS_LETTERS : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var _index : int = 0
var _selected : bool = false

@onready var _selection_visuals : Control = $SelectionVisuals


func _process(_delta : float) -> void:
	text = _INITIALS_LETTERS[_index]
	_selection_visuals.visible = _selected


func next_letter() -> void:
	_index = (_index + 1) % _INITIALS_LETTERS.length()


func previous_letter() -> void:
	_index = (_index - 1 + _INITIALS_LETTERS.length()) % _INITIALS_LETTERS.length()


func set_selected(selected : bool) -> void:
	_selected = selected


func is_selected() -> bool:
	return _selected


func get_letter() -> String:
	return _INITIALS_LETTERS[_index]
