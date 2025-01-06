extends Node3D

var PAUSED: bool = false

var master_rng := RandomNumberGenerator.new()
# bits 'n bobbles
const MINOTAUR = preload("res://minotaur/minotaur.gd")
const ITEM = preload("res://item/item.gd")
const ITEM_SPAWNER = preload("res://item/item_spawner.gd")
@onready var GM: GridMap = $GM
@onready var village: Node3D = $VILLAGE
const STARTING_INHAB_COUNT = 3

# maze settings
var maze_size := Vector2i(15,15)
var start_size := Vector2i(4,4)
var cell_size := Vector3(8, 6, 8)
#var maze_size := Vector2i(5,5)
#var start_size := Vector2i(6,6)
#var cell_size := Vector3(2,.1,2)
var balanced := false
var rooms := false

# time
enum {AM, PM}
enum {HOUR, MINUTE, PERIOD, DAY}
var world_time = Vector4i(11, 59, PM, -1)
var time_since_tick = 0
var IN_GAME_MINUTE_LENGTH_IN_REAL_WORLD_SECONDS = .5
signal world_tick(time: Vector4i)



func _ready():
	new_maze()
	bind_inputs()


func _process(delta): 
	if PAUSED: return
	if Input.is_action_pressed("random"): new_maze()
	
	time_since_tick += delta
	if time_since_tick > IN_GAME_MINUTE_LENGTH_IN_REAL_WORLD_SECONDS: 
		time_since_tick -= IN_GAME_MINUTE_LENGTH_IN_REAL_WORLD_SECONDS
		
		world_time[MINUTE] = (world_time[MINUTE] + 1) % 60
		if not world_time[MINUTE]: world_time[HOUR] = ((world_time[HOUR] + 1) % 12)
		if not (world_time[HOUR] or world_time[MINUTE]): world_time[PERIOD] = (world_time[PERIOD] + 1) % 2
		if !world_time[HOUR] and not (world_time[MINUTE] or world_time[PERIOD]): world_time[DAY] += 1
		
		world_tick.emit(world_time)

func pause(unpause: bool = false): PAUSED = not unpause


func new_maze():

	GM.queue_free()
	remove_child(GM)
	
	var generation_seed: = master_rng.randi()
	
	var real_start_size: Vector2
	if (generation_seed & ((1 << 16) - 1)) == 0xBEEF:
		# beef seed
		real_start_size = Vector2(2,2)
	else: 
		real_start_size = Vector2i(4,4)
	
	print("generating with seed: ", "%X" % generation_seed)
	var biomes: Array[int] = select_biomes(generation_seed)
	var maze = MINOTAUR.generate_four_biomes(maze_size, real_start_size, biomes, generation_seed)
	var descriptor = MINOTAUR.generate_descriptor(maze)
	GM = MINOTAUR.map_to_grid(descriptor, load("res://QuaterniusDev_models/map_tiles/finals/quat_meshs.tres"), true, cell_size)
	GM.collision_layer = DATA.LAYERS.MAP
	GM.collision_mask = DATA.LAYERS.PLAYER + DATA.LAYERS.ITEM
	
	var total_value = ITEM_SPAWNER.spawn_items_based(GM, descriptor, biomes, generation_seed)
	print("total value generated: ", total_value)
	
	var TM = MINOTAUR.map_to_tile(descriptor, load("res://imported_modules/LIBRARIES/default_tiles.tres"))
	village.init_village(TM, cell_size, STARTING_INHAB_COUNT)
	TM.queue_free()
	
	add_child(GM)


func select_biomes(seed: int = 0) -> Array[int]:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed if seed else int(Time.get_unix_time_from_system()*1000)
	var biomes: Array[int] = [0,0,0,0]
	
	for i in 4: 
		biomes[i] = rng.randi_range(0, DATA.BIOME_LIST.size()-1)
	return biomes

enum  {NAME, EVENT} 
func bind_inputs():
	const key_bindings = [
		["up", KEY_W],
		["left", KEY_A],
		["down", KEY_S],
		["right", KEY_D],
		["jump", KEY_SPACE],
		["sprint", KEY_SHIFT],
		["capture_mouse", KEY_ESCAPE],
		["interact", KEY_E],
		["random", KEY_R],
		["drop_item", KEY_C],
		["slot_one", KEY_1],
		["slot_two", KEY_2],
		["slot_three", KEY_3],
		["slot_four", KEY_4],
		["slot_five", KEY_5],
		["slot_six", KEY_6]
	]
	const mouse_bindings = [
		["use", MOUSE_BUTTON_LEFT],
		["scroll_down", MOUSE_BUTTON_WHEEL_DOWN],
		["scroll_up", MOUSE_BUTTON_WHEEL_UP]
	]
	
	for data in key_bindings:
		InputMap.add_action(data[NAME])
		var new_event = InputEventKey.new()
		new_event.keycode = data[EVENT]
		InputMap.action_add_event(data[NAME], new_event)
	
	for data in mouse_bindings:
		InputMap.add_action(data[NAME])
		var new_event = InputEventMouseButton.new()
		new_event.button_index = data[EVENT]
		InputMap.action_add_event(data[NAME], new_event)
