class_name MovablePlatformSprite
extends Sprite2D

@export var part : GeometryColorDefinitions.PlatformParts = GeometryColorDefinitions.PlatformParts.UNDEFINED


func _ready() -> void:
	_assign_texture()


func _assign_texture() -> void:
	match part:
		GeometryColorDefinitions.PlatformParts.LEFT:
			texture = GeometryColorDefinitions._PLATFORM_8_LEFT_TEXTURE_DICT[GameState.next_color]
		GeometryColorDefinitions.PlatformParts.MID:
			texture = GeometryColorDefinitions._PLATFORM_8_MID_TEXTURE_DICT[GameState.next_color]
		GeometryColorDefinitions.PlatformParts.RIGHT:
			texture = GeometryColorDefinitions._PLATFORM_8_RIGHT_TEXTURE_DICT[GameState.next_color]
		_:
			assert(false) # Invalid part, should never happen.
