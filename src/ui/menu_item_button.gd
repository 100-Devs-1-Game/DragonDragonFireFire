class_name MenuItemButton
extends Button

# Sometimes, we might not want to play the focus sound the very first time the elements gets into focus, e.g. when
# it's the very first button focused in a scene and it would sound weird to play a selection bug. This flag will
# then prevent playing the sound the very first time the button gets focus.
@export var dont_play_sound_on_first_focus : bool = false

var _has_ever_been_focus : bool = false

@onready var selection_arrow : TextureRect = $SelectionArrow


func _process(_delta : float) -> void:
	selection_arrow.visible = has_focus()


func _on_mouse_entered():
	grab_focus()


func _on_focus_entered():
	if _has_ever_been_focus or not dont_play_sound_on_first_focus:
		SoundPool.play_sound(SoundPool.SOUND_MENU_SWITCH)
	
	_has_ever_been_focus = true
