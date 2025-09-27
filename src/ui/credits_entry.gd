class_name CreditsEntry
extends Button

@export var entry_name : String = ""
@export var entry_role : String = ""
@export var entry_texture : Texture2D = null
@export var entry_link : String = ""

@onready var _image_rect : TextureRect = $Image
@onready var _name_label : Label = $NameLabel
@onready var _role_label : Label = $RoleLabel


func _ready() -> void:
	assert(entry_name != "")
	assert(entry_role != "")
	assert(entry_texture)

	_name_label.text = entry_name
	_role_label.text = entry_role
	_image_rect.texture = entry_texture


func _on_pressed():
	if entry_link != "":
		OS.shell_open(entry_link)


func _on_focus_entered():
	SoundPool.play_sound(SoundPool.SOUND_MENU_SWITCH)
