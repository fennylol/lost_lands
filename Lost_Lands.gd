extends Node3D

var PAUSED: bool = false

var master_rng := RandomNumberGenerator.new()
# bits 'n bobbles
const MINOTAUR = preload("res://minotaur/minotaur.gd")
const ITEM = preload("res://item/item.gd")
const ITEM_SPAWNER = preload("res://item/item_spawner.gd")
@onready var GM: GridMap = $GM
@onready var village: Node3D = $VILLAGE
@onready var items: Node3D = $ITEMS
const STARTING_INHAB_COUNT = 3

# maze settings
var maze_size := Vector2i(15,15)
var start_size := Vector2i(4,4)
var cell_size := Vector3(8, 6, 8)
#var maze_size := Vector2i(25,25)
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
	var maze = MINOTAUR.generate_four_biomes(maze_size, real_start_size, biomes, generation_seed) #MINOTAUR.generate_four_corners(maze_size, start_size, balanced, seed)
	var descriptor = MINOTAUR.generate_descriptor(maze)
	GM = MINOTAUR.map_to_grid(descriptor, load("res://QuaterniusDev_models/map_tiles/finals/quat_meshs.tres"), true, cell_size)

	var total_value = ITEM_SPAWNER.spawn_items_based(GM, descriptor, biomes, generation_seed)
	print("total value generated: ", total_value)
	
	var TM = MINOTAUR.map_to_tile(descriptor, load("res://imported_modules/LIBRARIES/default_tiles.tres"))
	village.init_village(TM, cell_size, STARTING_INHAB_COUNT)
	TM.queue_free()
	
	add_child(GM)


func select_biomes(seed: int = 0) -> Array[int]:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed if seed else int(Time.get_unix_time_from_system()*1000)
	
	var BIOME_LIST = load("res://biome_data.gd").BIOME_LIST
	var biomes: Array[int] = [0,0,0,0]
	
	for i in 4: 
		biomes[i] = rng.randi_range(0, BIOME_LIST.size()-1)
	return biomes


func bind_inputs():
	# ╭----------------╮
	# |    MOVEMENT    |
	# ╰----------------╯
	InputMap.add_action("left")
	var event_left = InputEventKey.new()
	event_left.keycode = KEY_A
	InputMap.action_add_event("left", event_left)
	
	InputMap.add_action("up")
	var event_up = InputEventKey.new()
	event_up.keycode = KEY_W
	InputMap.action_add_event("up", event_up)
	
	InputMap.add_action("right")
	var event_right = InputEventKey.new()
	event_right.keycode = KEY_D
	InputMap.action_add_event("right", event_right)
	
	InputMap.add_action("down")
	var event_down = InputEventKey.new()
	event_down.keycode = KEY_S
	InputMap.action_add_event("down", event_down)
	
	InputMap.add_action("jump")
	var event_jump = InputEventKey.new()
	event_jump.keycode = KEY_SPACE
	InputMap.action_add_event("jump", event_jump)
	
	InputMap.add_action("sprint")
	var event_sprint = InputEventKey.new()
	event_sprint.keycode = KEY_SHIFT
	InputMap.action_add_event("sprint", event_sprint)
	
	
	# ╭----------------╮
	# |   other lmao   |
	# ╰----------------╯
	InputMap.add_action("capture_mouse")
	var event_capture_mouse = InputEventKey.new()
	event_capture_mouse.keycode = KEY_ESCAPE
	InputMap.action_add_event("capture_mouse", event_capture_mouse)
	
	InputMap.add_action("interact")
	var event_interact = InputEventKey.new()
	event_interact.keycode = KEY_E
	InputMap.action_add_event("interact", event_interact)
	
	InputMap.add_action("use")
	var event_use = InputEventMouseButton.new()
	event_use.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("use", event_use)

	InputMap.add_action("scroll_down")
	var event_scroll_down = InputEventMouseButton.new()
	event_scroll_down.button_index = MOUSE_BUTTON_WHEEL_DOWN
	InputMap.action_add_event("scroll_down", event_scroll_down)

	InputMap.add_action("scroll_up")
	var event_scroll_up = InputEventMouseButton.new()
	event_scroll_up.button_index = MOUSE_BUTTON_WHEEL_UP
	InputMap.action_add_event("scroll_up", event_scroll_up)
	
	InputMap.add_action("random")
	var event_random = InputEventKey.new()
	event_random.keycode = KEY_R
	InputMap.action_add_event("random", event_random)
	
	InputMap.add_action("drop_item")
	var event_drop_item = InputEventKey.new()
	event_drop_item.keycode = KEY_C
	InputMap.action_add_event("drop_item", event_drop_item)
	
	#InputMap.add_action("__")
	#var event__ = InputEventMouseButton.new()
	#event__.button_index = 
	#InputMap.action_add_event("__", event__)
	#
	#InputMap.add_action("__")
	#var event__ = InputEventKey.new()
	#event__.keycode = KEY_R
	#InputMap.action_add_event("__", event__)
