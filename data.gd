class_name DATA extends RefCounted

enum LAYERS {PLAYER = 1, MAP = 2, ITEM = 4}

enum BIOME_FIELDS {NAME, DIFFICULTY, LOOT_POTENTIAL, MAZE_FLAGS, ITEMS}
enum MAZE_FLAGS {BALANCED, ROOMS}
enum ITEMS_RARITY {COMMON, RARE, AWOOGA}

# loot_potential is the average value contained at each potential spawn space. 
const BIOME_LIST = [
	[
		"basic",
		1,
		10,
		[false, false],
		[
			ITEM_LIST[ITEM_NAMES.THING],
			ITEM_LIST[ITEM_NAMES.APPLE],
			ITEM_LIST[ITEM_NAMES.GOLDEN_APPLE]
		]
	],
	[
		"balanced",
		2,
		10,
		[true, false],
		[
			ITEM_LIST[ITEM_NAMES.APPLE_CRATE],
			ITEM_LIST[ITEM_NAMES.APPLE]
		]
	],
	[
		"roomy",
		4,
		10,
		[false, true],
		[
			ITEM_LIST[ITEM_NAMES.MONKEY_IDOL],
			ITEM_LIST[ITEM_NAMES.APPLE]
		]
	],
	[
		"scary",
		8,
		10,
		[true, true],
		[
			ITEM_LIST[ITEM_NAMES.THING], 
			ITEM_LIST[ITEM_NAMES.APPLE_CRATE], 
			ITEM_LIST[ITEM_NAMES.MONKEY_IDOL],
			ITEM_LIST[ITEM_NAMES.APPLE],
			ITEM_LIST[ITEM_NAMES.GOLDEN_APPLE],
			ITEM_LIST[ITEM_NAMES.GOLDEN_APPLE]
		]
	]
]

static func get_biome_name(biome_index: int) -> String: return BIOME_LIST[biome_index][BIOME_FIELDS.NAME]
static func get_biome_difficulty(biome_index: int) -> int: return BIOME_LIST[biome_index][BIOME_FIELDS.DIFFICULTY]
static func get_biome_loot_potential(biome_index: int) -> int: return BIOME_LIST[biome_index][BIOME_FIELDS.LOOT_POTENTIAL]
static func get_biome_maze_flags(biome_index: int) -> Array: return BIOME_LIST[biome_index][BIOME_FIELDS.MAZE_FLAGS]
static func get_biome_items(biome_index: int) -> Array: return BIOME_LIST[biome_index][BIOME_FIELDS.ITEMS]
static func get_biome_item_value(biome_index: int, item_index: int) -> Vector3: return BIOME_LIST[biome_index][BIOME_FIELDS.ITEMS][item_index][ITEM_FIELDS.VALUES]


enum ITEM_FIELDS {NAME, MESH, COLLIDER, ICON, VALUES, SCRIPT}
enum ITEM_NAMES {THING, APPLE_CRATE, MONKEY_IDOL, APPLE, GOLDEN_APPLE}
const ITEM_LIST = [
	[
		"thing", 
		preload("res://imported_modules/LIBRARIES/_resources/obj mesh/OPEN.obj"), 
		preload("res://imported_modules/LIBRARIES/_resources/obj collider/OPEN.tres"), 
		preload("res://item/_resources/thing/thing_icon.png"),
		Vector3(10,2,3)
	],
	[
		"apple_crate", 
		preload("res://item/_resources/apple_crate/apple_crate.obj"), 
		preload("res://item/_resources/apple_crate/apple_crate_shape.tres"), 
		preload("res://item/_resources/apple_crate/apple_crate_icon.png"),
		Vector3(20,5,0)
	],
	[
		"monkey_idol",
		preload("res://item/_resources/idol/idol.obj"),
		preload("res://item/_resources/idol/idol_shape.tres"),
		preload("res://item/_resources/idol/idol_icon.png"),
		Vector3(0,0,30)
	],
	[
		"apple",
		preload("res://item/_resources/apple/apple.obj"),
		preload("res://item/_resources/apple/apple_shape.tres"),
		preload("res://item/_resources/apple/apple_icon.png"),
		Vector3(10,1,0)
	],
	[
		"golden_apple",
		preload("res://item/_resources/apple/golden_apple.obj"),
		preload("res://item/_resources/apple/apple_shape.tres"),
		preload("res://item/_resources/apple/golden_apple_icon.png"),
		Vector3(100,10,0)
	]
]

static func get_item_name(item_index: int) -> String: return ITEM_LIST[item_index][ITEM_FIELDS.NAME]
static func get_item_mesh(item_index: int) -> int: return ITEM_LIST[item_index][ITEM_FIELDS.MESH]
static func get_item_collider(item_index: int) -> int: return ITEM_LIST[item_index][ITEM_FIELDS.COLLIDER]
static func get_item_values(item_index: int) -> Array: return ITEM_LIST[item_index][ITEM_FIELDS.VALUES]
