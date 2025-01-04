extends Area3D

var values := Vector3.ZERO 
var icon

func get_icon(): if icon: return icon


const ITEM_FIELDS = preload("res://biome_data.gd").ITEM_FIELDS# {NAME, MESH, COLLIDER, VALUES, ICON, SCRIPT}
static func create_item_from_array(data: Array) -> Area3D:
	if data.size()-1 < ITEM_FIELDS.VALUES or \
					not (data[ITEM_FIELDS.NAME] is String \
					and data[ITEM_FIELDS.MESH] is Object\
					and data[ITEM_FIELDS.COLLIDER] is Object\
					and data[ITEM_FIELDS.ICON] is Object\
					and data[ITEM_FIELDS.VALUES] is Vector3):
		printerr("ERROR create_item_from_array(): data must be in the form of: 
				[\"NAME\", preload(MESH), preload(COLLIDER), Vector3(VALUES), ImageTexture(ICON)]")
		printerr("data[NAME]: ", typeof(data[ITEM_FIELDS.NAME]),
				"\ndata[MESH]: ", typeof(data[ITEM_FIELDS.MESH]), 
				"\ndata[COLLIDER]: ", typeof(data[ITEM_FIELDS.COLLIDER]), 
				"\ndata[ICON]: ", typeof(data[ITEM_FIELDS.ICON]), 
				"\ndata[VALUES]:", typeof(data[ITEM_FIELDS.VALUES]))
		return null
	
	var new_item = Area3D.new()
	var new_mesh := MeshInstance3D.new()
	var new_collider := CollisionShape3D.new()
	
	var script: Script = data[ITEM_FIELDS.COLLIDER] if data.size()-1 >= ITEM_FIELDS.SCRIPT else preload("res://item/item.gd")
	new_item.set_script(script)
	new_item.add_to_group("item")
	
	new_mesh.mesh = data[ITEM_FIELDS.MESH]
	new_collider.shape = data[ITEM_FIELDS.COLLIDER]
	new_item.values = data[ITEM_FIELDS.VALUES]
	var ico = ImageTexture.create_from_image(data[ITEM_FIELDS.ICON])
	new_item.icon =ico
	
	new_mesh.name = "MESH"
	new_collider.name = "COLLIDER"
	new_item.name = data[ITEM_FIELDS.NAME]
	
	new_item.add_child(new_mesh)
	new_item.add_child(new_collider)

	return new_item


#static func create_item(name: String, mesh: Mesh, collider: Shape3D, val: Vector3, input_icon: ImageTexture) -> Area3D:
	#var new_item = Area3D.new()
	#var new_mesh := MeshInstance3D.new()
	#var new_collider := CollisionShape3D.new()
	#
	#new_item.set_script(preload("res://item/item.gd"))
	#new_item.add_to_group("item")
	#
	#new_mesh.mesh = mesh
	#new_collider.shape = collider
	#new_item.values = val
	#new_item.icon = input_icon
	#
	#new_mesh.name = "MESH"
	#new_collider.name = "COLLIDER"
	#new_item.name = name
	#
	#new_item.add_child(new_mesh)
	#new_item.add_child(new_collider)
#
	#return new_item
