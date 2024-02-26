extends Node3D

var shadow_projector_nodes : Array[Node]
var shadow_projectors : Array[RayCast3D]

@onready var shadow_decal : Decal = $ShadowDecal

func _ready():
	shadow_projector_nodes = $ShadowProjectors.get_children()
	for shadow_projector_node in shadow_projector_nodes:
		if shadow_projector_node is RayCast3D:
			var shadow_projector : RayCast3D = shadow_projector_node
			shadow_projectors.append(shadow_projector)
		else:
			printerr("ShadowProjectors child is not RayCast3D")

func _process(_delta):
	var position_y : float = 0
	for shadow_projector : RayCast3D in shadow_projectors:
		if shadow_projector.is_colliding():
			var new_position_y : float = shadow_projector.get_collision_point().y
			if new_position_y > position_y:
				position_y = new_position_y
	shadow_decal.global_position.y = position_y
