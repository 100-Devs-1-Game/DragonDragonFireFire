class_name MenuScreen
extends Control

@export var initial_focus : MenuItemButton = null
@export var store_previous_selection : bool = false

var _previously_visited : bool = false
var _previous_selection : Control = null

var is_active : bool = false


func activate() -> void:
	visible = true
	is_active = true
	_set_initial_focus()


func deactivate() -> void:
	if not is_active:
		visible = false
		return

	is_active = false
	_previously_visited = true
	var focus_owner : Control = get_viewport().gui_get_focus_owner()
	if store_previous_selection and focus_owner:
		_previous_selection = focus_owner
	else:
		_previous_selection = null
	
	visible = false


func _set_initial_focus() -> void:
	if _previously_visited and _previous_selection and store_previous_selection:
		_previous_selection.grab_focus()
	elif initial_focus:
		initial_focus.grab_focus()
