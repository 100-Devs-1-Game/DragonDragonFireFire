class_name PlayerCutscene
extends Node2D

@onready var _sprite_head : AnimatedSprite2D = $AnimatedSprite2DHead
@onready var _sprite_body : AnimatedSprite2D = $AnimatedSprite2DBody


var dissolve_shader_time : float = 0.0


func _process(_delta : float) -> void:
	var shader_material : ShaderMaterial = get("material") as ShaderMaterial
	assert(shader_material)
	shader_material.set_shader_parameter("current_time", dissolve_shader_time)
	

func play_head(animation : String) -> void:
	_sprite_head.play(animation)


func play_body(animation : String) -> void:
	_sprite_body.play(animation)


func pause() -> void:
	_sprite_head.pause()
	_sprite_body.pause()
