extends Control

# value labels
@onready var FOOD_VALUE: Label = $top/values/FOOD_VALUE
@onready var WOOD_VALUE: Label = $top/values/WOOD_VALUE
@onready var SCRAP_VALUE: Label = $top/values/SCRAP_VALUE
@onready var TIME_LABEL: Label = $top/values/date_time/TIME
@onready var DATE_LABEL: Label = $top/values/date_time/DATE

func _ready():
	var adjust_sizing = func():
		pass
	
	adjust_sizing.call()
	get_tree().root.size_changed.connect(adjust_sizing)

# ╭------------╮
# |   values   |
# ╰------------╯
func set_values(vals: Vector3i):
	set_food_value(vals.x)
	set_wood_value(vals.y)
	set_scrap_value(vals.z)

func set_food_value(val: float):
	var base_string = "Food at the village: "
	FOOD_VALUE.text = base_string + str(val)

func set_wood_value(val: float):
	var base_string = "Wood at the village: "
	WOOD_VALUE.text = base_string + str(val)

func set_scrap_value(val: float):
	var base_string = "Scrap at the village: "
	SCRAP_VALUE.text = base_string + str(val)




