class_name PlayerCutscene
extends Node2D

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D


func play(animation : String) -> void:
	_sprite.play(animation)
