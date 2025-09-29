class_name StageDefinitions
extends Resource

const HELLO_WALKER : PackedScene = preload("res://stages/hello_walker.tscn")
const HELLO_FLYER : PackedScene = preload("res://stages/hello_flyer.tscn")
const THE_TOWER : PackedScene = preload("res://stages/the_tower.tscn")
const HELLO_SHOOTER : PackedScene = preload("res://stages/hello_shooter.tscn")
const ALL_TOGETHER : PackedScene = preload("res://stages/all_together.tscn")
const CRAZY_PLATFORMS : PackedScene = preload("res://stages/crazy_platforms.tscn")
const SHOOTER_MADNESS : PackedScene = preload("res://stages/shooter_madness.tscn")
const CRAZY_HOLES : PackedScene = preload("res://stages/crazy_holes.tscn")

const STAGES_DICT : Dictionary[int, PackedScene] = {
	1: HELLO_WALKER,
	2: HELLO_FLYER,
	3: THE_TOWER,
	4: HELLO_SHOOTER,
	5: ALL_TOGETHER,
	6: CRAZY_PLATFORMS,
	7: SHOOTER_MADNESS,
	8: CRAZY_HOLES
}
