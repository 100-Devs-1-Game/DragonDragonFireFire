class_name PlayerCutscene
extends Node2D

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D

var dissolve_shader_time : float = 0.0


func _process(_delta : float) -> void:
	var shader_material : ShaderMaterial = get("material") as ShaderMaterial
	assert(shader_material)
	shader_material.set_shader_parameter("current_time", dissolve_shader_time)
	

func play(animation : String) -> void:
	_sprite.play(animation)


func pause() -> void:
	_sprite.pause()
