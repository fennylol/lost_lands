extends VBoxContainer




func _ready():
	var adjust_sizing = func():
		var size = get_viewport_rect().size.y * 0.2
		var inv = $inventory
		inv.custom_minimum_size.y = size
		inv.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		
		var top_height = get_viewport_rect().size.y * 0.4
		var top = $top
		var minimap = $top/displays/MINIMAP
		var dials = $top/displays/dials
		
		# Set top's height to 20% of screen
		top.custom_minimum_size.y = top_height
		top.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		# Minimap takes up 2/3 of that height
		var minimap_size = top_height * (2.0/3.0)
		minimap.custom_minimum_size = Vector2(minimap_size, minimap_size)

		# Each dial takes up roughly the remaining vertical space (1/3 of top_height)
		var dial_size = top_height * (1.0/3.0)
		for dial in dials.get_children():
			dial.custom_minimum_size = Vector2(dial_size, dial_size)
			for dial_face in dial.get_children():
				dial_face.pivot_offset = Vector2(dial_size, dial_size)/2
				dial_face.custom_minimum_size = Vector2(dial_size, dial_size)
	
	adjust_sizing.call()
	get_tree().root.size_changed.connect(adjust_sizing)


func _process(delta):
	if not visible: return
	if maximap: update_minimap_display(delta)
	update_compass_rotation(delta)

# ╭-------------╮
# |  inventory  |
# ╰-------------╯
var EMPTY = preload("res://item/_resources/empty_icon.png")
var ACTIVE = preload("res://item/_resources/slot.png")
var INACTIVE = preload("res://item/_resources/slot_inactive.png")
@onready var inventory = [$inventory/SLOT_0,$inventory/SLOT_1,$inventory/SLOT_2,$inventory/SLOT_3]

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
@onready var minimap = $top/displays/MINIMAP as TextureRect
var minimap_range = 75 as int
var cell_size: Vector3
var tile_size: Vector3
var last_player_pos := Vector3i.ZERO
var target_rotation: float = 0.0
var maximap: Image
var player_color := Color.AQUA
var player_border_color := Color.WEB_GRAY
var markers: bool = false

func show_minimap(show: bool = true): minimap.visible = show
func show_markers(show: bool = true): markers = show

func set_minimap(img: Image, scale: Vector3):
	maximap = img
	cell_size = scale
	var subset_rect := Rect2i(Vector2i.ZERO,Vector2i(2*(minimap_range),2*minimap_range))
	minimap.texture = ImageTexture.create_from_image(maximap.get_region(subset_rect))

func tilemap_to_image(tilemap: TileMap, save_resource: bool = false, resource_path: String = "res://gui/_resources/minimap.png") -> Image:
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
	
	if save_resource: image.save_png(resource_path)
	return image

func new_player_color(): player_color = Color(randf(),randf(),randf(),1)

func adjust_target_rotation(amount: float): target_rotation += amount


func update_minimap_display(delta: float):
	minimap.rotation = lerp(minimap.rotation, target_rotation, 7.5*delta)
	var minimap_boarder_thickness: int = max(minimap_range/30,2)
	var active_inhab: CharacterBody3D = get_parent().get_parent()
	# the position is divided by 2 because the default size of gridmaps is 2x2x2 meters
	var player_pos := Vector3i(((active_inhab.position/cell_size/2)*tile_size)+Vector3(maximap.get_size().x/2, 0, maximap.get_size().y/2))
	
	if player_pos != last_player_pos or !delta:
		last_player_pos = player_pos
		
		var clear_color := Color(0,0,0,0)
		var base_color := Color(0,0,0,0.5)
		var minimap_border_color := clear_color#Color.DIM_GRAY
		
		if markers: maximap.set_pixel(player_pos.x, player_pos.z, player_color*0.8)
		
		#var minimap_boarder_thickness: int = 3
		var player_icon_size: int = 2

		var rect_pos := Vector2i(player_pos.x - minimap_range, player_pos.z - minimap_range) 
		var rect_size := Vector2i(2*minimap_range,2*minimap_range)
		
		var subset_img := Image.create(rect_size.x, rect_size.y, false, Image.FORMAT_RGBA8)
		for x in rect_size.x:
			for y in rect_size.y:
				var pixel_pos = Vector2(x, y)
				var distance = pixel_pos.distance_to(Vector2(minimap_range, minimap_range))
				var c: Color = base_color
				
				if distance < player_icon_size: c = player_color
				elif distance < player_icon_size+1: c = player_border_color
				elif distance > minimap_range-minimap_boarder_thickness and distance < minimap_range: c = minimap_border_color
				elif distance < minimap_range: 
					if x+rect_pos.x < maximap.get_size().x and y+rect_pos.y < maximap.get_size().y and x+rect_pos.x >= 0 and y+rect_pos.y >= 0:
						c = maximap.get_pixel(x+rect_pos.x,y+rect_pos.y)
				else: c = clear_color
				subset_img.set_pixel(x,y,c)
		
		minimap.texture.update(subset_img) 
	minimap.pivot_offset = Vector2i((minimap.size.x+minimap_boarder_thickness)/2,(minimap.size.y+minimap_boarder_thickness)/2)


# ╭-------------╮
# |   compass   |
# ╰-------------╯
var angular_velocity: float = 0.0
@onready var clock_display = $top/displays/dials/clock/clock_progress
@onready var compass_display = $top/displays/dials/compass/compass_progress

func show_compass(show: bool = true): $top/displays/dials/compass.visible = show

func update_compass_rotation(delta):
	var damping_factor = 0.975
	var spring_strength: float = 5.0 
	
	var diff = target_rotation - compass_display.rotation
	var acceleration = spring_strength * diff
	
	angular_velocity += acceleration * delta
	angular_velocity *= damping_factor
	compass_display.rotation += angular_velocity * delta
	
	if abs(diff) < 0.001 and abs(angular_velocity) < 0.001:
		compass_display.rotation = target_rotation
		angular_velocity = 0.0


# ╭----------╮
# |   time   |
# ╰----------╯
enum {HOUR, MINUTE, PERIOD, DAY}

func show_clock(show: bool = true): $top/displays/dials/clock.visible = show

func rotate_clock(time: Vector4i):
	var hour = 12 - time[HOUR] + time[PERIOD]*12 
	var minute = time[MINUTE]
	clock_display.rotation_degrees = hour*(360/24) - minute*(15.0/60.0)
