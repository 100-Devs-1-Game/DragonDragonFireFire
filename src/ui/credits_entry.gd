class_name CreditsEntry
extends Button

@export var entry_name : String = ""
@export var entry_role : String = ""
@export var entry_texture : Texture2D = null

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
