extends Node3D


const INHAB = preload("res://inhabitant/inhabitant.tscn")
@onready var INHABITANTS = $INHABITENTS
@onready var DROPZONE = $DROPZONE
@onready var GUI: Control = $Gui
var inhabitant_count: int = 0
var mouse_captured: bool = false

const DEFAULT_RESOURCE_COUNTS := Vector3(1100,1100,0)#Vector3(11,11,0)
const DEFAULT_RESOURCE_DECAY_RATES := Vector3(0.0166, 0.0166, 0)
const DEFAULT_INHABITANT_MULTIPLIER: float = 1

var resource_counts := DEFAULT_RESOURCE_COUNTS
var resource_decay_rates := DEFAULT_RESOURCE_DECAY_RATES
var inhabitant_multiplier := DEFAULT_INHABITANT_MULTIPLIER

var max_dist: float = INF

var total_collected := Vector3.ZERO

func _ready():
	get_parent().world_tick.connect(process_world_tick)


enum {AM, PM}
enum {HOUR, MINUTE, PERIOD, DAY}
func process_world_tick(time: Vector4i):
	GUI.process_world_tick(time)
	resource_counts -= resource_decay_rates * inhabitant_multiplier * INHABITANTS.get_child_count()
	GUI.set_values(Vector3i(resource_counts))
	if resource_counts.x <= 0 or resource_counts.y <= 0: handle_loss()
	if INHABITANTS.get_child_count():
		INHABITANTS.get_child(0).process_world_tick(time)
		if INHABITANTS.get_child(0).position.y < 0: INHABITANTS.get_child(0).take_damage(10000)
	
	if time[PERIOD] == AM && (time[HOUR] == 0 || time[HOUR] == 1 || time[HOUR] == 2):
		GUI.set_alert("ITS GETTING LATE", 1, 1)
		for inhab in INHABITANTS.get_children():
			if inhab.position.distance_to(position) > max_dist: 
				inhab.take_damage(sqrt((inhab.position.distance_to(position) - max_dist))/10)
	elif time[PERIOD] == AM && time[HOUR] == 5:
		var str = "The morning of day " + str(time[DAY])
		GUI.set_alert(str, 5, 1)
	
	
	collect_resources_from_items()





func init_village(map, cell_size, kill_dist, spawn_count: int = 3):
	kill_all_inhabitants()
	
	# create INHABITANTS
	inhabitant_count = spawn_count
	for i in spawn_count:
		# create a new inhabitant in the center of the village
		var inhabitant_name = "krug_"+str(i)
		var new_inhabitant = spawn_inhabitant(inhabitant_name)
		new_inhabitant.init_gui(map, cell_size)
	
	max_dist = kill_dist
	
	# pass control to one of the inhabitents
	posess_next_inhabitant()
	
	# handle resources
	resource_counts = DEFAULT_RESOURCE_COUNTS
	total_collected = Vector3.ZERO
	
	GUI.set_values(resource_counts)
	var new_trip = func(body):
		if !body.is_in_group("inhabitant"): return
		if body.get_markers(): body.new_player_color()
	if !DROPZONE.body_entered.is_connected(new_trip): DROPZONE.body_entered.connect(new_trip)


func handle_loss(): 
	kill_all_inhabitants()
	var str = "YOU LOST\nTOTAL FOOD GATHERED: " + str(total_collected.x) + \
					  "\nTOTAL WOOD GATHERED: " + str(total_collected.y) + \
					  "\nTOTAL SCRAP GATHERED: " + str(total_collected.z)
	GUI.set_alert(str)


# ╭-----------╮
# |   items   |
# ╰-----------╯
func collect_resources_from_items():
	var bodies: Array = DROPZONE.get_overlapping_bodies()
	if bodies.size():
		for body in bodies:
			if body.is_in_group("item"):
				resource_counts += body.values
				total_collected += body.values
				body.queue_free()
			#elif body.is_in_group("inhabitant"):
				#var item = body.remove_item(body.active_slot)
				#if item: resource_counts += item.values


# ╭-----------------╮
# |   INHABITANTS   |
# ╰-----------------╯
func get_active_inhabitant() -> CharacterBody3D:
	if INHABITANTS.get_child_count(): return INHABITANTS.get_child(0)
	else: return null


func posess_next_inhabitant():
	if !INHABITANTS.get_child_count(): return
	INHABITANTS.get_child(0).get_child(0).current = true
	INHABITANTS.get_child(0).show_gui(true)


func kill_all_inhabitants():
	for child in INHABITANTS.get_children(): child.take_damage(10000)

# rotation
func _unhandled_input(event):
	if event is InputEventMouseMotion and mouse_captured and INHABITANTS.get_child_count():
		var amount: Vector2 = -event.relative * 0.005
		INHABITANTS.get_child(0).rotate_inhabitant(amount)


# movement
func _physics_process(delta):
	var input_dir := Vector2.ZERO
	var jump: bool = false
	var sprint: bool = false
	
	if mouse_captured:
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()
		var auto_bhop = true # lol
		if Input.is_action_just_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")): jump = true
	
	if INHABITANTS.get_child_count():
		INHABITANTS.get_child(0).handle_inputs(input_dir, jump)

var show_minimap: bool = false
var show_markers: bool = false
var show_compass: bool = false
var show_clock: bool = false
var show_light: bool = false
# mouse capture
func _process(delta):
	if Input.is_action_just_pressed("capture_mouse") or \
	Input.is_action_just_pressed("use") and not mouse_captured:
		mouse_captured = !mouse_captured
		if mouse_captured: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif INHABITANTS.get_child_count():
		if Input.is_action_just_pressed("interact"):
			INHABITANTS.get_child(0).interact()
		if Input.is_action_just_pressed("drop_item"):
			INHABITANTS.get_child(0).drop_item()
		if Input.is_action_just_pressed("scroll_down"):
			print(INHABITANTS.get_child(0).scroll())
		elif Input.is_action_just_pressed("scroll_up"):
			INHABITANTS.get_child(0).scroll(true)
		
		if Input.is_action_pressed("drop_item"):
			if Input.is_action_just_pressed("left"): 
				show_minimap = !show_minimap
				INHABITANTS.get_child(0).show_minimap(show_minimap)
			if Input.is_action_just_pressed("up"): 
				show_markers = !show_markers
				INHABITANTS.get_child(0).show_markers(show_markers)
			if Input.is_action_just_pressed("right"): 
				show_compass = !show_compass
				INHABITANTS.get_child(0).show_compass(show_compass)
			if Input.is_action_just_pressed("down"): 
				show_clock = !show_clock
				INHABITANTS.get_child(0).show_clock(show_clock)
			if Input.is_action_just_pressed("interact"):
				show_light = !show_light
				INHABITANTS.get_child(0).show_light(show_light)


func spawn_inhabitant(inhabitant_name: String = "krug") -> CharacterBody3D:
	var new_inhabitant = INHAB.instantiate()
	new_inhabitant.name = inhabitant_name
	new_inhabitant.position.y += 1.5
	new_inhabitant.position.x += randi_range(-5,5)
	new_inhabitant.position.z += randi_range(-5,5)
	INHABITANTS.add_child(new_inhabitant)
	
	var handle_take_damage = func(val): 
		print(inhabitant_name, " health: ", val)
		if val <= 0: print(inhabitant_name, " died...")
	
	new_inhabitant.health_changed.connect(handle_take_damage)
	new_inhabitant.dead.connect(handle_inhabitant_death)
	return new_inhabitant


func handle_inhabitant_death():
	inhabitant_count -= 1
	
	if !inhabitant_count: handle_loss()
	else:
		INHABITANTS.remove_child(INHABITANTS.get_child(0))
		posess_next_inhabitant()
