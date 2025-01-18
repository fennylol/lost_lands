class_name DATA extends RefCounted


enum LAYERS {PLAYER = 1, MAP = 2, ITEM = 4}

enum BIOME_FIELDS {NAME, LOOT_POTENTIAL, MAZE_FLAGS, ITEMS}
enum MAZE_FLAGS {BALANCED, ROOMS}
enum ITEMS_RARITY {COMMON, RARE, AWOOGA}

# loot_potential is the average value contained at each potential spawn space. 
const BIOME_LIST = [
	[
		"basic",
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
		10,
		[true, false],
		[
			ITEM_LIST[ITEM_NAMES.APPLE_CRATE],
			ITEM_LIST[ITEM_NAMES.APPLE]
		]
	],
	[
		"roomy",
		10,
		[false, true],
		[
			ITEM_LIST[ITEM_NAMES.MONKEY_IDOL],
			ITEM_LIST[ITEM_NAMES.APPLE]
		]
	],
	[
		"scary",
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
	],
	[
		"the_kitchen",
		30,
		[true, true],
		[
			ITEM_LIST[ITEM_NAMES.APPLE],
			ITEM_LIST[ITEM_NAMES.GOLDEN_APPLE],
			ITEM_LIST[ITEM_NAMES.BOTTLE],
			ITEM_LIST[ITEM_NAMES.BURGER],
			ITEM_LIST[ITEM_NAMES.LETTUCE],
			ITEM_LIST[ITEM_NAMES.PIZZA],
			ITEM_LIST[ITEM_NAMES.SPOON]
		]
	],
	[
		"loot_vault",
		100,
		[false, true],
		[
			ITEM_LIST[ITEM_NAMES.THING],
			ITEM_LIST[ITEM_NAMES.MONKEY_IDOL],
			ITEM_LIST[ITEM_NAMES.SPOON],
			ITEM_LIST[ITEM_NAMES.PIZZA],
			ITEM_LIST[ITEM_NAMES.GOLDEN_APPLE],
		]
	],
]
#[
		#"",
		#0,
		#[false, false],
		#[
			#ITEM_LIST[ITEM_NAMES.],
		#]
	#],


static func get_biome_name(biome_index: int) -> String: return BIOME_LIST[biome_index][BIOME_FIELDS.NAME]
static func get_biome_loot_potential(biome_index: int) -> int: return BIOME_LIST[biome_index][BIOME_FIELDS.LOOT_POTENTIAL]
static func get_biome_maze_flags(biome_index: int) -> Array: return BIOME_LIST[biome_index][BIOME_FIELDS.MAZE_FLAGS]
static func get_biome_items(biome_index: int) -> Array: return BIOME_LIST[biome_index][BIOME_FIELDS.ITEMS]
static func get_biome_item_value(biome_index: int, item_index: int) -> Vector3: return BIOME_LIST[biome_index][BIOME_FIELDS.ITEMS][item_index][ITEM_FIELDS.VALUES]


enum ITEM_FIELDS {NAME, MESH, COLLIDER, ICON, VALUES, HAND_SCALE, IS_LARGE, SCRIPT}
enum ITEM_NAMES {THING, APPLE_CRATE, MONKEY_IDOL, APPLE, GOLDEN_APPLE, BOTTLE, BURGER, LETTUCE, PIZZA, SPOON}
const ITEM_LIST = [
	[
		"thing", 
		preload("res://imported_modules/LIBRARIES/_resources/obj mesh/OPEN.obj"), 
		preload("res://item/_resources/thing/thing_shape.tres"), 
		preload("res://item/_resources/thing/thing_icon.png"),
		Vector3(0,20,1),
		Vector3(.75,.75,.75),
		true
	],
	[
		"apple crate", 
		preload("res://item/_resources/apple_crate/apple_crate.obj"), 
		preload("res://item/_resources/apple_crate/apple_crate_shape.tres"), 
		preload("res://item/_resources/apple_crate/apple_crate_icon.png"),
		Vector3(20,5,0),
		Vector3(1,1,1),
		true
	],
	[
		"monkey idol",
		preload("res://item/_resources/idol/idol.obj"),
		preload("res://item/_resources/idol/idol_shape.tres"),
		preload("res://item/_resources/idol/idol_icon.png"),
		Vector3(0,0,30),
		Vector3(1,1,1),
		false
	],
	[
		"apple",
		preload("res://item/_resources/apple/apple.obj"),
		preload("res://item/_resources/apple/apple_shape.tres"),
		preload("res://item/_resources/apple/apple_icon.png"),
		Vector3(10,1,0),
		Vector3(3,3,3),
		false
	],
	[
		"golden apple",
		preload("res://item/_resources/apple/golden_apple.obj"),
		preload("res://item/_resources/apple/apple_shape.tres"),
		preload("res://item/_resources/apple/golden_apple_icon.png"),
		Vector3(100,10,0),
		Vector3(3,3,3),
		false
	],
	[
		"bottle",
		preload("res://item/_resources/bottle/Bottle1.obj"),
		preload("res://item/_resources/bottle/bottle_shape.tres"),
		preload("res://item/_resources/bottle/bottle_icon.png"),
		Vector3(5,1,5),
		Vector3(1,1,1),
		false
	],
	[
		"burger",
		preload("res://item/_resources/cheeseburger/BurgerLarge.obj"),
		preload("res://item/_resources/cheeseburger/huge_burger_shape.tres"),
		preload("res://item/_resources/cheeseburger/huge_burger_icon.png"),
		Vector3(20,0,0),
		Vector3(1,1,1),
		true
	],
	[
		"lettuce",
		preload("res://item/_resources/lettuce/Lettuce_Whole.obj"),
		preload("res://item/_resources/lettuce/lettuce_shape.tres"),
		preload("res://item/_resources/lettuce/lettuce_icon.png"),
		Vector3(10,1,0),
		Vector3(1,1,1),
		false
	],
	[
		"pizza",
		preload("res://item/_resources/pizza/Pizza.obj"),
		preload("res://item/_resources/pizza/pizza_shape.tres"),
		preload("res://item/_resources/pizza/pizza_icon.png"),
		Vector3(15,0,0),
		Vector3(1,1,1),
		true
	],
	[
		"spoon",
		preload("res://item/_resources/spoon/Spoon.obj"),
		preload("res://item/_resources/spoon/spoon_shape.tres"),
		preload("res://item/_resources/spoon/spoon_icon.png"),
		Vector3(20,20,20),
		Vector3(2,2,2),
		true
	],
]
#[
		#"",
		#preload(),
		#preload(),
		#preload(),
		#Vector3(,,),
		#false,
		#Vector3(1,1,1)
	#],

#static func get_item_name(item_index: int) -> String: return ITEM_LIST[item_index][ITEM_FIELDS.NAME]
#static func get_item_mesh(item_index: int) -> int: return ITEM_LIST[item_index][ITEM_FIELDS.MESH]
#static func get_item_collider(item_index: int) -> int: return ITEM_LIST[item_index][ITEM_FIELDS.COLLIDER]
#static func get_item_values(item_index: int) -> Array: return ITEM_LIST[item_index][ITEM_FIELDS.VALUES]



enum RECIPE_FIELDS {NAME, ICON, COST}
const CRAFTING_RECIPES = [
	[
		"clock",
		null,
		Vector3(0,0,10)
	],
	[
		"compass",
		null,
		Vector3(0,0,10)
	],
	[
		"minimap",
		null,
		Vector3(0,0,30)
	],
	[
		"markers",
		null,
		Vector3(0,0,10)
	],
	[
		"flash light",
		null,
		Vector3(0,0,10)
	]
]
