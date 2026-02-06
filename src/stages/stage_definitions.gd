class_name StageDefinitions
extends Resource

const HELLO_WALKER : PackedScene = preload("res://stages/hello_walker.tscn")
const HELLO_FLYER : PackedScene = preload("res://stages/hello_flyer.tscn")
const HELLO_SHOOTER : PackedScene = preload("res://stages/hello_shooter.tscn")
const THE_TOWER : PackedScene = preload("res://stages/the_tower.tscn")
const SHOOTER_STAIRS : PackedScene = preload("res://stages/shooter_stairs.tscn")
const ALL_TOGETHER : PackedScene = preload("res://stages/all_together.tscn")
const HELLO_SWEEPER : PackedScene = preload("res://stages/hello_sweeper.tscn")
const CRAZY_PLATFORMS : PackedScene = preload("res://stages/crazy_platforms.tscn")
const SHOOTER_MADNESS : PackedScene = preload("res://stages/shooter_madness.tscn")
const CRAZY_HOLES : PackedScene = preload("res://stages/crazy_holes.tscn")
const BIG_BOX : PackedScene = preload("res://stages/big_box.tscn")
const CROWDED_PLATFORMS : PackedScene = preload("res://stages/crowded_platforms.tscn")
const PLATFORM_PUZZLE : PackedScene = preload("res://stages/platform_puzzle.tscn")
const FINALE : PackedScene = preload("res://stages/finale.tscn")
const BONUS : PackedScene = preload("res://stages/bonus.tscn")

const STAGES_DICT : Dictionary[int, PackedScene] = {
	1: HELLO_WALKER,
	2: HELLO_FLYER,
	3: HELLO_SHOOTER,
	4: THE_TOWER,
	5: SHOOTER_STAIRS,
	6: ALL_TOGETHER,
	7 : HELLO_SWEEPER,
	8: CRAZY_PLATFORMS,
	9: SHOOTER_MADNESS,
	10: CRAZY_HOLES,
	11: BIG_BOX,
	12: CROWDED_PLATFORMS,
	13: PLATFORM_PUZZLE,
	14: FINALE,
	15: BONUS,
}
