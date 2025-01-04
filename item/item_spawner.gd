const ITEM = preload("res://item/item.gd")
const BIOME_DATA = preload("res://biome_data.gd")
const ITEM_LIST = BIOME_DATA.ITEM_LIST
const SPAWN_RATE_VARIENCE: float = 0.15
const LOOT_POTENTIAL_VARIENCE: float = 0.33



static func spawn_items_based(gm: GridMap, map_descriptor: Array, biomes: Array, generation_seed: int = 0) -> float:
	for y in map_descriptor.size():
		if map_descriptor[y].size() != map_descriptor[0].size(): 
			printerr("ERROR spawn_items(): inconsistent maze dimentions")
			return 0
	
	var total_value: float = 0
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed if generation_seed else int(Time.get_unix_time_from_system()*1000)
	
	var spawns := find_spawns_by_quadrant(map_descriptor)
	
	for quad_idx in spawns.size():
		# find budget for quad
		var lp: float = BIOME_DATA.get_biome_loot_potential(biomes[quad_idx])
		var max_budget: float = lp * (1+LOOT_POTENTIAL_VARIENCE)
		var min_budget: float = lp * (1-LOOT_POTENTIAL_VARIENCE)
		var spawnable_tiles: int = spawns[quad_idx][SPAWN_TYPES.ENDS].size() \
							 	 + spawns[quad_idx][SPAWN_TYPES.CORNERS].size() \
							 	 + spawns[quad_idx][SPAWN_TYPES.JUNCTIONS].size()
		var quad_budget: float = rng.randf_range(min_budget, max_budget) * spawnable_tiles
		#print("generating quad_", quad_idx,". budget: ", snappedf(quad_budget, 2), ". tile_count: ", spawnable_tiles)

		# spawn starting with ENDS, then CORNERS, then JUNCTIONS
		for type in SPAWN_TYPES:
			#print("generating ", type, " in quad_", quad_idx," ", " with budget remaining: ", quad_budget)
			# attempt one spawn at a random location for each valid location
			for i in spawns[quad_idx][SPAWN_TYPES[type]].size():
				if quad_budget <= 0: 
					#print("no more budget in quad_", quad_idx," ", type)
					break
				# determine random spawn point and remove from list
				var pos_rand: int = rng.randi_range(0, spawns[quad_idx][SPAWN_TYPES[type]].size()-1)
				var pos: Vector2i = spawns[quad_idx][SPAWN_TYPES[type]].pop_at(pos_rand)
				
				# roll for spawn success
				var spawn_rand = rng.randi_range(0,max_budget)
				#if success and not already spawned in, spawn
				if spawn_rand <= quad_budget and pos:
					# select item and create
					var item_list = BIOME_DATA.get_biome_items(biomes[quad_idx])
					var item_idx = rng.randi_range(0,item_list.size()-1)
					var new_item = ITEM.create_item_from_array(item_list[item_idx])
					
					# position item, add to map and lower loot potential
					new_item.position = gm.map_to_local(Vector3(pos.x,0,pos.y))
					gm.add_child(new_item)
					var value = BIOME_DATA.get_biome_item_value(biomes[quad_idx], item_idx).length()
					quad_budget -= value
					total_value += value
					#printerr("spawned at ",pos," costing ", value)
			
			
		#print("final budget for quad_", quad_idx,": ", quad_budget, "\n")
	return total_value



enum SPAWN_TYPES {ENDS, CORNERS, JUNCTIONS}
static func find_spawns_by_quadrant(descriptor: Array) -> Array:
	var x_size = descriptor[0].size()
	for y in descriptor.size():
		if descriptor[y].size() != x_size: 
			printerr("ERROR find_spawns_by_quadrent(): inconsistent descriptor dimentions")
			return []
	
	
	var spawns := [
		[[],[],[]],
		[[],[],[]],
		[[],[],[]],
		[[],[],[]]
	]
	#var spawns := [
		#[],[],[],[]
	#]
	var half_y := int(descriptor.size()/2)
	var half_x := int(descriptor[0].size()/2)
	for y in descriptor.size():
		for x in descriptor[0].size():
			# ╭--╮ ╭--╮
			# |0 ╰-╯ 1|
			# ╰╮     ╭╯
			# ╭╯     ╰╮
			# |2 ╭-╮ 3|
			# ╰--╯ ╰--╯
			var quad_idx = int(y > half_y)*2 + int(x > half_x)
			if TILE_TYPE[descriptor[y][x]] == END:  
				spawns[quad_idx][SPAWN_TYPES.ENDS].push_back(Vector2(x,y))
			elif TILE_TYPE[descriptor[y][x]] == CORNER:  
				spawns[quad_idx][SPAWN_TYPES.CORNERS].push_back(Vector2(x,y))
			elif TILE_TYPE[descriptor[y][x]] == JUNCTION:  
				# dont test edge (heh) cases, avoid central room
				if y and y < descriptor.size()-1 and x and x < descriptor[0].size()-1:
					if  TILE_TYPE[descriptor[y+1][x]] == OPEN or \
						TILE_TYPE[descriptor[y-1][x]] == OPEN or \
						TILE_TYPE[descriptor[y][x+1]] == OPEN or \
						TILE_TYPE[descriptor[y][x-1]] == OPEN: continue
				spawns[quad_idx][SPAWN_TYPES.JUNCTIONS].push_back(Vector2(x,y))
	return spawns

enum {CLOSED, END, STRAIGHT, CORNER, JUNCTION, OPEN}
const TILE_TYPE = [CLOSED,END,END,CORNER,END,STRAIGHT,CORNER,JUNCTION,END,CORNER,STRAIGHT,JUNCTION,CORNER,JUNCTION,JUNCTION,OPEN]
const TILES = {
	0:  CLOSED,
	1:  END,
	2:  END,
	4:  END,
	8:  END,
	5:  STRAIGHT,
	10: STRAIGHT,
	3:  CORNER,
	6:  CORNER,
	9:  CORNER,
	12: CORNER,
	7:  JUNCTION,
	11: JUNCTION,
	13: JUNCTION,
	14: JUNCTION,
	15: OPEN
}

#static func spawn_items(gm: GridMap, map_descriptor: Array, generation_seed: int = 0):
	#for y in map_descriptor.size():
		#if map_descriptor[y].size() != map_descriptor[0].size(): 
			#printerr("ERROR spawn_items(): inconsistent maze dimentions")
			#return 
	#
	#var rng := RandomNumberGenerator.new()
	#rng.seed = generation_seed if generation_seed else int(Time.get_unix_time_from_system()*1000)
	#
	#for y in map_descriptor.size():
		#for x in map_descriptor[0].size():
			#var rand = randi_range(0,10)
			#if map_descriptor[y][x] and not rand: 
				#var item_idx = rng.randi_range(0,ITEM_LIST.size()-1)
				#var new_item = ITEM.create_item_from_array(ITEM_LIST[item_idx]) #ITEM.create_item(ITEM_LIST[item_idx][NAME], ITEM_LIST[item_idx][MESH], ITEM_LIST[item_idx][COLLIDER], ITEM_LIST[item_idx][VALUES])
				#new_item.position = gm.map_to_local(Vector3(x,0,y))
				#gm.add_child(new_item)
