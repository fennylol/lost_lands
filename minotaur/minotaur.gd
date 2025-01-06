enum DIR_VAL {N = 1, E = 2, S = 4, W = 8}
enum DIR {CLOSED,   N,   E,   NE,
		  S,        NS,  ES,  NES,
		  W,        NW,  EW,  NEW,
		  SW,       NSW, ESW, OPEN}
# ╭----------------╮
# |     CUSTOM     |
# ╰----------------╯
static func generate_four_corners(corner_size: Vector2i, center_size: Vector2i, balanced: bool = false, generation_seed: int = 0):
	if corner_size.x < 1 or corner_size.y < 1: 
		printerr("ERROR generate_four_corners(): maze must be minimum 1x1")
		return []
	#if center_size.x < 4 or center_size.y < 4:
		#printerr("ERROR generate_four_corners(): center must be minimum 4x4. continuing...")
		#return []
	
	# create random number generator with provided or random generation_seed
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed if generation_seed else int(Time.get_unix_time_from_system()*1000)
	
	
	var maze = generate_points_inverted(corner_size)
	fill_maze_recursive_split(maze, Vector2i(maze.size(), maze[0].size()), balanced, rng)
	
	var maze2 = generate_points_inverted(corner_size)
	fill_maze_recursive_split_with_room(maze2, Vector2i(maze2.size(), maze2[0].size()), balanced, rng)
	
	
	var empty_spacer = []
	empty_spacer.resize(maze.size()-1)
	empty_spacer.fill(0)
	
	var center_room = []
	center_room.resize(center_size.x-2)
	center_room.fill(1)
	
	var center_gap = []
	center_gap.resize(center_size.x-2)
	center_gap.fill(0)
	
	var center_row = []
	center_row.append_array(empty_spacer)
	center_row.append_array(center_room)
	center_row.append_array([1,1])
	center_row.append_array(empty_spacer)
	#center_row.append_array([1])
	
	for i in maze.size():
		maze[i].append_array(center_room if i+1==maze.size() else center_gap)
		maze[i].append_array(maze2[i])
	
	for i in center_size.x-2:
		maze.append(center_row)
	
	
	maze2 = generate_points_inverted(corner_size)
	fill_maze_recursive_split(maze2, Vector2i(maze2.size(), maze2[0].size()), !balanced, rng)
	
	var maze3 = generate_points_inverted(corner_size)
	fill_maze_recursive_split_with_room(maze3, Vector2i(maze3.size(), maze3[0].size()), !balanced, rng)
	
	for i in maze2.size():
		maze2[i].append_array(center_room if !i else center_gap)
		maze2[i].append_array(maze3[i])
		maze.append(maze2[i])
	
	
	return maze



static func generate_four_biomes(corner_size: Vector2i, center_size: Vector2i, biomes: Array[int], generation_seed: int = 0):
	if corner_size.x < 1 or corner_size.y < 1: 
		printerr("ERROR generate_four_biomes(): maze must be minimum 1x1")
		return []
	#if center_size.x < 4 or center_size.y < 4:
		#printerr("ERROR generate_four_biomes(): center must be minimum 4x4.")
		#return []
	if biomes.size() != 4: 
		printerr("ERROR generate_four_biomes(): must be exactly 4 biomes.")
		return []
	
	# create random number generator with provided or random generation_seed
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed if generation_seed else int(Time.get_unix_time_from_system()*1000)
	
	var BIOME_LIST = DATA.BIOME_LIST
	var mazes := []
	mazes.resize(4)
	
	for i in 4:
		mazes[i] = generate_points_inverted(corner_size)
		var size := Vector2i(mazes[i].size(), mazes[i][0].size())
		var flags: Array = DATA.get_biome_maze_flags(biomes[i])
		var balanced: bool = flags[DATA.MAZE_FLAGS.BALANCED]
		var rooms: bool = flags[DATA.MAZE_FLAGS.ROOMS]
		
		if rooms: fill_maze_recursive_split_with_room(mazes[i], size, balanced, rng)
		else: fill_maze_recursive_split(mazes[i], size, balanced, rng)
	
	
	#var maze = generate_points_inverted(corner_size)
	#fill_maze_recursive_split(maze, Vector2i(maze.size(), maze[0].size()), balanced, rng)
	#
	#var maze2 = generate_points_inverted(corner_size)
	#fill_maze_recursive_split_with_room(maze2, Vector2i(maze2.size(), maze2[0].size()), balanced, rng)
	
	
	var empty_spacer = []
	empty_spacer.resize(mazes[0].size()-1)
	empty_spacer.fill(0)
	
	var center_room = []
	center_room.resize(center_size.x-2)
	center_room.fill(1)
	
	var center_gap = []
	center_gap.resize(center_size.x-2)
	center_gap.fill(0)
	
	var center_row = []
	center_row.append_array(empty_spacer)
	center_row.append_array(center_room)
	center_row.append_array([1,1])
	center_row.append_array(empty_spacer)
	#center_row.append_array([1])
	
	for i in mazes[0].size():
		mazes[0][i].append_array(center_room if i+1==mazes[0].size() else center_gap)
		mazes[0][i].append_array(mazes[1][i])
	
	for i in center_size.x-2:
		mazes[0].append(center_row)
	
	#
	#maze2 = generate_points_inverted(corner_size)
	#fill_maze_recursive_split(maze2, Vector2i(maze2.size(), maze2[0].size()), !balanced, rng)
	#
	#var maze3 = generate_points_inverted(corner_size)
	#fill_maze_recursive_split_with_room(maze3, Vector2i(maze3.size(), maze3[0].size()), !balanced, rng)
	
	for i in mazes[2].size():
		mazes[2][i].append_array(center_room if !i else center_gap)
		mazes[2][i].append_array(mazes[3][i])
		mazes[0].append(mazes[2][i])
	
	return mazes[0]




# ╭----------------╮
# |   GENERATORS   |
# ╰----------------╯
static func generate_maze(size: Vector2i, balanced: bool = false, generation_seed: int = 0) -> Array:
	if size.x < 1 or size.y < 1: 
		printerr("ERROR generate_maze(): maze must be minimum 1x1")
		return []
	
	# create random number generator with provided or random generation_seed
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed if generation_seed else int(Time.get_unix_time_from_system()*1000)
	
	var maze = generate_points_inverted(size)
	fill_maze_recursive_split(maze, Vector2i(maze.size(), maze[0].size()), balanced, rng)
	return maze



static func generate_maze_with_rooms(size: Vector2i, balanced: bool = false, generation_seed: int = 0) -> Array:
	if size.x < 1 or size.y < 1: 
		printerr("ERROR generate_maze(): maze must be minimum 1x1")
		return []
	
	# create random number generator with provided or random generation_seed
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed if generation_seed else int(Time.get_unix_time_from_system()*1000)
	
	var maze = generate_points_inverted(size)
	fill_maze_recursive_split_with_room(maze, Vector2i(maze.size(), maze[0].size()), balanced, rng)
	
	for y in maze.size():
		for x in maze[y].size():
			if !maze[y][x]:
				if x+1 >= maze[y].size() or !maze[y][x+1]: continue
				if x-1 < 0 or !maze[y][x-1]: continue
				if y+1 >= maze.size() or !maze[y+1][x]: continue
				if y-1 < 0 or !maze[y-1][x]: continue
				maze[y][x] = 1
	
	return maze



# INSPECT: X and Y axis may be flipped. 
static func generate_points(size: Vector2i) -> Array:
	var map : Array
	
	var col = []
	col.resize((size.y*2)+1)
	for i in col.size(): col[i] = (i%2)
	
	var wall_col = []
	wall_col.resize((size.y*2)+1)
	wall_col.fill(0)
	
	map.resize((size.x*2)+1)
	for i in map.size(): map[i] = col.duplicate(true) if (i%2) else wall_col.duplicate(true) 
	
	return map



static func generate_points_inverted(size: Vector2i) -> Array:
	var map : Array = []
	
	var row = []
	row.resize((size.x*2)+1)
	for i in row.size(): row[i] = 1-(i%2)
	
	var path_row = []
	path_row.resize((size.x*2)+1)
	path_row.fill(1)
	
	map.resize((size.y*2)+1)
	for i in map.size(): map[i] = row.duplicate(true) if (i%2) else path_row.duplicate(true) 
	
	return map



static func generate_descriptor(map: Array) -> Array:
	var descriptor := []
	
	for y in map.size():
		# create empty row
		var row = []
		
		for x in map[y].size():
			if map[y][x] == 0: 
				row.append(0)
			else:
				# start with all walls open
				var val = 15
				
				# close walls in N->E->S->W order
				if y == 0               or map[y-1][x] == 0: val -= DIR_VAL.N
				if x == map[y].size()-1 or map[y][x+1] == 0: val -= DIR_VAL.E
				if y == map.size()-1    or map[y+1][x] == 0: val -= DIR_VAL.S
				if x == 0               or map[y][x-1] == 0: val -= DIR_VAL.W
				row.append(val)
		
		# add row to descriptor
		descriptor.append(row)
	
	return descriptor

# ╭----------------╮
# |    FILLERS     |
# ╰----------------╯
# https://youtu.be/184Oair5iys?si=sTYP-8xwd3xd5j_J
static func fill_maze_recursive_split(map: Array, limits: Vector2i, balanced: bool = false, rng: RandomNumberGenerator = RandomNumberGenerator.new(), origin: Vector2i = Vector2i.ZERO, split_horz: bool = true):
	if limits.x < 3 or limits.y < 3: return
	
	var l = limits.y if split_horz else limits.x
	var o = origin.y if split_horz else origin.x
	var split_len = limits.x if split_horz else limits.y
	
	var s = 0
	if balanced:
		s = o+((l-1)/2) 
	else:
		s = rng.randi_range(o+1, o+l-1) 
	var oddinator = (1-(s%2)) 
	var split = s - oddinator if l != 3 else o+1 
	
	var g = rng.randi_range(0, split_len-1)
	var eveninator = (g%2)
	
	if split_horz:
		for i in split_len:
			map[origin.x + i][split] = 0
		map[origin.x + g + eveninator][split] = 1
	else:
		for i in split_len:
			map[split][origin.y + i] = 0
		map[split][origin.y + g + eveninator] = 1
	
	var org_0 = origin
	var lim_0 = Vector2i(limits.x, split-o) if split_horz else Vector2i(split-o, limits.y)
	var org_1 = origin + (Vector2i(0,(split-o)+1) if split_horz else Vector2i((split-o)+1,0))
	var lim_1 =  Vector2i(limits.x, limits.y-(org_1.y-o)) if split_horz else Vector2i(limits.x-(org_1.x-o), limits.y)
	fill_maze_recursive_split(map, lim_0, balanced, rng, org_0, !split_horz)
	fill_maze_recursive_split(map, lim_1, balanced, rng, org_1, !split_horz)



static func fill_maze_recursive_split_with_room(map: Array, limits: Vector2i, balanced: bool = false, rng: RandomNumberGenerator = RandomNumberGenerator.new(), origin: Vector2i = Vector2i.ZERO, split_horz: bool = true):
	if limits.x < 3 or limits.y < 3: return
	
	var l = limits.y if split_horz else limits.x
	var o = origin.y if split_horz else origin.x
	var split_len = limits.x if split_horz else limits.y
	
	var s = 0
	if balanced:
		s = o+((l-1)/2) 
	else:
		s = rng.randi_range(o+1, o+l-1) 
	var oddinator = (1-(s%2)) 
	var split = s - oddinator if l != 3 else o+1 
	
	var g = rng.randi_range(0, split_len-1)
	var eveninator = (g%2)
	var g2 = rng.randi_range(0, split_len-1)
	var eveninator2 = (g2%2)
	
	if split_horz:
		for i in split_len:
			map[origin.x + i][split] = 0
		map[origin.x + g + eveninator][split] = 1
		map[origin.x + g2 + eveninator2][split] = 1
	else:
		for i in split_len:
			map[split][origin.y + i] = 0
		map[split][origin.y + g + eveninator] = 1
		map[split][origin.y + g2 + eveninator2] = 1
	
	var org_0 = origin
	var lim_0 = Vector2i(limits.x, split-o) if split_horz else Vector2i(split-o, limits.y)
	var org_1 = origin + (Vector2i(0,(split-o)+1) if split_horz else Vector2i((split-o)+1,0))
	var lim_1 =  Vector2i(limits.x, limits.y-(org_1.y-o)) if split_horz else Vector2i(limits.x-(org_1.x-o), limits.y)
	fill_maze_recursive_split_with_room(map, lim_0, balanced, rng, org_0, !split_horz)
	fill_maze_recursive_split_with_room(map, lim_1, balanced, rng, org_1, !split_horz)



# ╭----------------╮
# |    MAPPERS     |
# ╰----------------╯
static func map_to_tile(map: Array, tiles: TileSet) -> TileMap:
	var TM = TileMap.new()
	TM.tile_set = tiles
	
	if tiles.get_source(0).get_tiles_count() < 16: 
		printerr("ERROR map_to_tile(): TileSet must contain all 16 permutations")
		return TM
	
	var x_size = map[0].size()
	for y in map.size():
		if map[y].size() != x_size: 
			printerr("ERROR map_to_tile(): inconsistent maze dimentions")
			return TM
	
	for y in map.size():
		for x in map[y].size():
			var atlas_x: int = (map[y][x])%4 
			var atlas_y: int = (int) ((map[y][x])/4)
			TM.set_cell(0, Vector2i(x, y), 0, Vector2i(atlas_x, atlas_y))
	return TM



static func map_to_grid(map: Array, meshs: MeshLibrary, reduced_tileset = false, grid_scale: Vector3 = Vector3i.ZERO) -> GridMap:
	var GM = GridMap.new()
	GM.name = "GM"
	GM.mesh_library = scale_all_mesh_items(meshs, grid_scale) if grid_scale else meshs
	GM.cell_size *= grid_scale
	GM.cell_center_y = false
	
	if meshs.get_item_list().size() < 16 and not reduced_tileset: 
		printerr("ERROR map_to_grid(): MeshLibrary must contain all 16 permutations")
		return GM
	elif meshs.get_item_list().size() < 6 and reduced_tileset: 
		printerr("ERROR map_to_grid(): MeshLibrary must contain all 6 permutations")
		return GM
	
	var x_size = map[0].size()
	for y in map.size():
		if map[y].size() != x_size: 
			printerr("ERROR map_to_grid(): inconsistent maze dimentions")
			return GM
	
	if reduced_tileset:
		for y in map.size():
			for x in map[y].size():
				var type: int = REDUCE_DIR[map[y][x]][MESH]
				var rot: int = REDUCE_DIR[map[y][x]][ROTATION]
				if not type:
					var rots = [0,10,16,22]
					rot = rots[randi_range(0,3)]
				GM.set_cell_item(Vector3i(x,0,y), type, rot)
	else:
		for y in map.size():
			for x in map[y].size():
				GM.set_cell_item(Vector3i(x,0,y), map[y][x])
				
	GM.position -= Vector3(map[0].size()*GM.cell_size.x,0,map.size()*GM.cell_size.z)/2
	return GM

# maps a descriptor to a MeshLibrary item and GridMap rotation
enum {MESH, ROTATION}
const REDUCE_DIR = {
	0:  [0,0],										# EMPTY/CLOSED
	1:  [1,0],  2:  [1,22], 4:  [1,10], 8:  [1,16], # END
	5:  [2,0],  10: [2,22],							# STRAIGHT
	3:  [3,0],  6:  [3,22], 9:  [3,16], 12: [3,10], # CORNER
	7:  [4,22], 11: [4,0],  13: [4,16], 14: [4,10], # JUNCTION
	15: [5,0]										# OPEN
}


static func scale_all_mesh_items(mesh_library: MeshLibrary, scale: Vector3) -> MeshLibrary:
	var new_library := MeshLibrary.new()

	for item_index in mesh_library.get_item_list():
	# Copy mesh
		new_library.create_item(item_index)
		var mesh: Mesh = mesh_library.get_item_mesh(item_index)
		if mesh:
			new_library.set_item_mesh(item_index, mesh)
		new_library.set_item_mesh_transform(item_index, mesh_library.get_item_mesh_transform(item_index).scaled(scale))
	
		# Copy and scale shapes
		var shapes = mesh_library.get_item_shapes(item_index)
		for i in range(0, shapes.size(), 2):
			var shape: Shape3D = shapes[i]
			var transform: Transform3D = shapes[i + 1]
			transform = transform.scaled(scale)
			new_library.set_item_shapes(item_index, [shape, transform])
	
		# Copy other properties
		new_library.set_item_name(item_index, mesh_library.get_item_name(item_index))
		new_library.set_item_preview(item_index, mesh_library.get_item_preview(item_index))

	return new_library
