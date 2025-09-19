class_name Teleport
extends RefCounted

const _TELEPORT_SRC_Y : float = 196.0
const _TELEPORT_DEST_Y : float = 0.0

const _TELEPORT_DIFF : float = _TELEPORT_DEST_Y - _TELEPORT_SRC_Y


static func handle_teleport(body : CharacterBody2D):
	if body.global_position.y >= _TELEPORT_SRC_Y:
		body.global_position.y += _TELEPORT_DIFF
