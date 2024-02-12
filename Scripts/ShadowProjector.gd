extends RayCast3D

@onready var shadow_decal : Decal = $ShadowDecal

func _process(_delta):
	if is_colliding():
		shadow_decal.global_position.y = get_collision_point().y
		var new_scale : float = 1.0 / (2.0 + (0.5 * (global_position.y - shadow_decal.global_position.y)))
		print(new_scale)
		shadow_decal.scale = Vector3(new_scale, new_scale, new_scale)
