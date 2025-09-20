class_name BurnParameters
extends Resource


# Source position of the burn.
var source_pos : Vector2 = Vector2.ZERO

# Time the source has been burning already.
var source_burn_time : float = 0.0

# Range around the source position where objects can be ignited.
var ignition_range : float = 0.0

# Whether to force immediate ignition of objects, ignoring certain conditions.
var force_immediate : bool = false

# Whether this burn source scares away enemies.
var scares_enemies : bool = false
