class_name GeometryColorDefinitions
extends RefCounted

enum Colors
{
	BLUE,
	GREEN,
	RED,
	PINK,
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