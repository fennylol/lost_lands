extends Control

# value labels
@onready var FOOD_VALUE: Label = $top/values/FOOD_VALUE
@onready var WOOD_VALUE: Label = $top/values/WOOD_VALUE
@onready var SCRAP_VALUE: Label = $top/values/SCRAP_VALUE
@onready var TIME_LABEL: Label = $top/values/date_time/TIME
@onready var DATE_LABEL: Label = $top/values/date_time/DATE
@onready var CRAFTING: VBoxContainer = $crafting
@onready var ALERT_LABEL: Label = $"crafting/ALERT SYSTEM"
var alert_duration: float = 0.0
var alert_fadeout_time: float = 0.0

func _ready():
	var adjust_sizing = func():
		pass
	
	adjust_sizing.call()
	get_tree().root.size_changed.connect(adjust_sizing)

func _process(delta):
	if alert_duration >= -1.0:
		alert_duration -= delta
		var c: Color = ALERT_LABEL.modulate
		ALERT_LABEL.modulate = Color(c.r, c.g, c.b, smoothstep(0.0, alert_fadeout_time, alert_duration))


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

enum {HOUR, MINUTE, PERIOD, DAY}
func process_world_tick(time: Vector4i):
	if not time[MINUTE] % 5:
		var hour = str(time[HOUR] if time[HOUR] else 12)  
		var minute = str(time[MINUTE]).pad_zeros(2)
		var period = "PM" if time[PERIOD] else "AM" 
		TIME_LABEL.text = hour + ":" + minute + " " + period
		DATE_LABEL.text = "day: " + str(time[DAY]) 


func set_alert(str: String, duration: float = 5.0, fade_out_time: float = 1.0):
	ALERT_LABEL.text = str
	alert_duration = duration
	alert_fadeout_time = fade_out_time
	


