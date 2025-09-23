class_name Initial
extends Label

const _INITIALS_LETTERS : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const _FLASH_SPEED : float = 6.0

var _index : int = 0
var _selected : bool = false
var _flash_time : float = 0.0

@onready var _selection_visuals : Control = $SelectionVisuals


func _process(_delta : float) -> void:
	text = _INITIALS_LETTERS[_index]
	_selection_visuals.visible = _selected

	if _selected:
		_flash_time += _delta
		self_modulate.a = 1.0 if int(_flash_time * _FLASH_SPEED) % 2 == 0 else 0.5
	else:
		self_modulate.a = 1.0


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
