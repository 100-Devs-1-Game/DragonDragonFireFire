class_name GeometryColorDefinitions
extends RefCounted

enum Colors
{
	BLUE,
	GREEN,
	RED,
	PINK,
}

enum PlatformParts
{
	UNDEFINED,
	LEFT,
	MID,
	RIGHT,
}

const _TILESET_TEXTURE_PINK : Texture2D = preload("res://assets/geometry/tileset_pink.png")
const _TILESET_TEXTURE_BLUE : Texture2D = preload("res://assets/geometry/tileset_blue.png")
const _TILESET_TEXTURE_GREEN : Texture2D = preload("res://assets/geometry/tileset_green.png")
const _TILESET_TEXTURE_RED : Texture2D = preload("res://assets/geometry/tileset_red.png")

const _TILESET_TEXTURE_DICT : Dictionary[Colors, Texture2D] = {
	Colors.PINK: _TILESET_TEXTURE_PINK,
	Colors.BLUE: _TILESET_TEXTURE_BLUE,
	Colors.GREEN: _TILESET_TEXTURE_GREEN,
	Colors.RED: _TILESET_TEXTURE_RED,
}

const _BOX_8_TEXTURE_PINK : Texture2D = preload("res://assets/geometry/burnable_block_8_pink.png")
const _BOX_8_TEXTURE_BLUE : Texture2D = preload("res://assets/geometry/burnable_block_8_blue.png")
const _BOX_8_TEXTURE_GREEN : Texture2D = preload("res://assets/geometry/burnable_block_8_green.png")
const _BOX_8_TEXTURE_RED : Texture2D = preload("res://assets/geometry/burnable_block_8_red.png")

# Intentionally swapped colors for more visual clarity.
const _BOX_8_TEXTURE_DICT : Dictionary[Colors, Texture2D] = {
	Colors.PINK: _BOX_8_TEXTURE_GREEN, 
	Colors.BLUE: _BOX_8_TEXTURE_RED,
	Colors.GREEN: _BOX_8_TEXTURE_PINK,
	Colors.RED: _BOX_8_TEXTURE_BLUE,
}

const _BOX_16_TEXTURE_PINK : Texture2D = preload("res://assets/geometry/burnable_block_16_pink.png")
const _BOX_16_TEXTURE_BLUE : Texture2D = preload("res://assets/geometry/burnable_block_16_blue.png")
const _BOX_16_TEXTURE_GREEN : Texture2D = preload("res://assets/geometry/burnable_block_16_green.png")
const _BOX_16_TEXTURE_RED : Texture2D = preload("res://assets/geometry/burnable_block_16_red.png")

# Intentionally swapped colors for more visual clarity.
const _BOX_16_TEXTURE_DICT : Dictionary[Colors, Texture2D] = {
	Colors.PINK: _BOX_16_TEXTURE_GREEN, 
	Colors.BLUE: _BOX_16_TEXTURE_RED,
	Colors.GREEN: _BOX_16_TEXTURE_PINK,
	Colors.RED: _BOX_16_TEXTURE_BLUE,
}

const _PLATFORM_8_LEFT_TEXTURE_PINK : Texture2D = preload("res://assets/geometry/platform_movable_8_left_pink.png")
const _PLATFORM_8_LEFT_TEXTURE_BLUE : Texture2D = preload("res://assets/geometry/platform_movable_8_left_blue.png")
const _PLATFORM_8_LEFT_TEXTURE_GREEN : Texture2D = preload("res://assets/geometry/platform_movable_8_left_green.png")
const _PLATFORM_8_LEFT_TEXTURE_RED : Texture2D = preload("res://assets/geometry/platform_movable_8_left_red.png")
const _PLATFORM_8_MID_TEXTURE_PINK : Texture2D = preload("res://assets/geometry/platform_movable_8_mid_pink.png")
const _PLATFORM_8_MID_TEXTURE_BLUE : Texture2D = preload("res://assets/geometry/platform_movable_8_mid_blue.png")
const _PLATFORM_8_MID_TEXTURE_GREEN : Texture2D = preload("res://assets/geometry/platform_movable_8_mid_green.png")
const _PLATFORM_8_MID_TEXTURE_RED : Texture2D = preload("res://assets/geometry/platform_movable_8_mid_red.png")
const _PLATFORM_8_RIGHT_TEXTURE_PINK : Texture2D = preload("res://assets/geometry/platform_movable_8_right_pink.png")
const _PLATFORM_8_RIGHT_TEXTURE_BLUE : Texture2D = preload("res://assets/geometry/platform_movable_8_right_blue.png")
const _PLATFORM_8_RIGHT_TEXTURE_GREEN : Texture2D = preload("res://assets/geometry/platform_movable_8_right_green.png")
const _PLATFORM_8_RIGHT_TEXTURE_RED : Texture2D = preload("res://assets/geometry/platform_movable_8_right_red.png")

const _PLATFORM_8_LEFT_TEXTURE_DICT : Dictionary[Colors, Texture2D] = {
	Colors.PINK: _PLATFORM_8_LEFT_TEXTURE_PINK,
	Colors.BLUE: _PLATFORM_8_LEFT_TEXTURE_BLUE,
	Colors.GREEN: _PLATFORM_8_LEFT_TEXTURE_GREEN,
	Colors.RED: _PLATFORM_8_LEFT_TEXTURE_RED,
}

const _PLATFORM_8_MID_TEXTURE_DICT : Dictionary[Colors, Texture2D] = {
	Colors.PINK: _PLATFORM_8_MID_TEXTURE_PINK,
	Colors.BLUE: _PLATFORM_8_MID_TEXTURE_BLUE,
	Colors.GREEN: _PLATFORM_8_MID_TEXTURE_GREEN,
	Colors.RED: _PLATFORM_8_MID_TEXTURE_RED,
}

const _PLATFORM_8_RIGHT_TEXTURE_DICT : Dictionary[Colors, Texture2D] = {
	Colors.PINK: _PLATFORM_8_RIGHT_TEXTURE_PINK,
	Colors.BLUE: _PLATFORM_8_RIGHT_TEXTURE_BLUE,
	Colors.GREEN: _PLATFORM_8_RIGHT_TEXTURE_GREEN,
	Colors.RED: _PLATFORM_8_RIGHT_TEXTURE_RED,
}
