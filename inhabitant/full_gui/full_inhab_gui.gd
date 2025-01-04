extends VBoxContainer

var EMPTY = preload("res://item/_resources/empty_icon.png")
var ACTIVE = preload("res://item/_resources/slot.png")
var INACTIVE = preload("res://item/_resources/slot_inactive.png")
@onready var inventory = [$inventory/SLOT_0,$inventory/SLOT_1,$inventory/SLOT_2,$inventory/SLOT_3]

func _ready():
	var adjust_sizing = func():
		var size = get_viewport_rect().size.y * 0.2
		var inv = $inventory
		inv.custom_minimum_size.y = size
		inv.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	adjust_sizing.call()
	get_tree().root.size_changed.connect(adjust_sizing)



func set_inventory_icon(icon: ImageTexture, slot: int):
	inventory[slot].texture = icon

func clear_inventory_icon(slot: int):
	inventory[slot].texture = EMPTY

func set_active_slot(slot: int): 
	for i in inventory.size():
		var img = ACTIVE if slot == i else INACTIVE
		var child = inventory[i].get_child(0)
		child.texture = ImageTexture.create_from_image(img)

#func set_inventory_slot_count(count: int = 4):
	#var inven = $inventory
	#const slot_scene = preload("res://inhabitant/slot.tscn")
	#
	#var end_spacer = $inventory/end_spacer
	#var mid_spacer = $inventory/spacer
	#
	#for i in count:
		#var slot = slot_scene.instantiate()
		#slot.name = "SLOT_" + str(i)
		#inven.add_child(slot)
		#if i != count-1: inven.add_child(mid_spacer.duplicate())
		#inventory.push_back(slot)
		#inven.move_child(end_spacer, inven.get_child_count()-1)


# ╭-------------╮
# |   minimap   |
# ╰-------------╯
func tilemap_to_image(tilemap: TileMap) -> Image:
	# Get the used cells and bounds
	var used_cells = tilemap.get_used_cells(0)  # 0 is the default layer
	if used_cells.is_empty():
		return null
	
	tile_size = Vector3i(tilemap.tile_set.tile_size.x, 0, tilemap.tile_set.tile_size.y)
	
	# Find bounds of the tilemap
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for cell in used_cells:
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	
	# Calculate dimensions
	var width = (max_x - min_x + 1) * tilemap.tile_set.tile_size.x
	var height = (max_y - min_y + 1) * tilemap.tile_set.tile_size.y
	
	# Create a viewport to render the tilemap
	var viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.size = Vector2i(width, height)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# Create a temporary tilemap for rendering
	var temp_tilemap = TileMap.new()
	temp_tilemap.tile_set = tilemap.tile_set
	
	# Copy tiles to the temporary tilemap, offsetting to start at 0,0
	for cell in used_cells:
		var source_id = tilemap.get_cell_source_id(0, cell)
		var atlas_coords = tilemap.get_cell_atlas_coords(0, cell)
		var alternative_tile = tilemap.get_cell_alternative_tile(0, cell)
		temp_tilemap.set_cell(0, Vector2i(cell.x - min_x, cell.y - min_y), 
			source_id, atlas_coords, alternative_tile)
	
	# Add nodes to scene tree temporarily
	viewport.add_child(temp_tilemap)
	add_child(viewport)
	
	# Wait for the viewport to finish rendering
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Get the image
	var image = viewport.get_texture().get_image()
	
	# Cleanup
	viewport.queue_free()
	
	image.save_png("res://gui/_resources/minimap.png")
	return image


func set_minimap(img: Image, scale: Vector3):
	maximap = img
	cell_size = scale
	var subset_rect := Rect2i(Vector2i.ZERO,Vector2i(2*(minimap_range),2*minimap_range))
	minimap.texture = ImageTexture.create_from_image(maximap.get_region(subset_rect))
	#minimap.texture = ImageTexture.create_from_image(img)
