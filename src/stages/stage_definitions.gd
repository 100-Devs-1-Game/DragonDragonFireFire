class_name StageDefinitions
extends Resource

const STAGE_1 : PackedScene = preload("res://stages/stage_1.tscn")
const STAGE_2 : PackedScene = preload("res://stages/stage_2.tscn")
const STAGE_3 : PackedScene = preload("res://stages/stage_3.tscn")

const STAGES_DICT : Dictionary[int, PackedScene] = {
	1: STAGE_1,
	2: STAGE_2,
	3: STAGE_3,
}
