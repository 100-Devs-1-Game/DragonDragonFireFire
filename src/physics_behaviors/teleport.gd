class_name Teleport
extends RefCounted

const _TELEPORT_BOTTOM_SRC_Y : float = 204.0
const _TELEPORT_BOTTOM_DEST_Y : float = 20.0

const _TELEPORT_TOP_SRC_Y : float = 12.0
const _TELEPORT_TOP_DEST_Y : float = 196.0

const _TELEPORT_DIFF : float = _TELEPORT_BOTTOM_DEST_Y - _TELEPORT_BOTTOM_SRC_Y


static func handle_teleport(body : CharacterBody2D):
	if body.global_position.y >= _TELEPORT_BOTTOM_SRC_Y:
		body.global_position.y += _TELEPORT_DIFF

	elif body.global_position.y <= _TELEPORT_TOP_SRC_Y:
		body.global_position.y -= _TELEPORT_DIFF
