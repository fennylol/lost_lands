#extends Area3D
class_name ITEM extends RigidBody3D

var values := Vector3.ZERO
var is_large: bool = false
var hand_scale := Vector3(1,1,1)

 
var icon: ImageTexture
var mesh: MeshInstance3D

func get_icon() -> ImageTexture: return icon if icon else null
func set_mesh_scale(s: Vector3 = Vector3(1,1,1)): if mesh: mesh.scale = s
