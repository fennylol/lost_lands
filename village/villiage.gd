extends Node3D


const INHAB = preload("res://inhabitant/inhabitant.tscn")
@onready var inhabitants = $INHABITENTS
@onready var dropzone = $DROPZONE
@onready var gui: Control = $Gui
var inhabitant_count: int = 0
var mouse_captured: bool = false

const DEFAULT_RESOURCE_COUNTS := Vector3(11,11,0)
const DEFAULT_RESOURCE_DECAY_RATES := Vector3(0.0166, 0.0166, 0)
const DEFAULT_INHABITANT_MULTIPLIER: float = 1

var resource_counts := DEFAULT_RESOURCE_COUNTS
var resource_decay_rates := DEFAULT_RESOURCE_DECAY_RATES
var inhabitant_multiplier := DEFAULT_INHABITANT_MULTIPLIER


func _ready():
	get_parent().world_tick.connect(process_world_tick)

func process_world_tick(time: Vector4i):
	#gui.update_time_display(time)
	resource_counts -= resource_decay_rates * inhabitant_multiplier * inhabitants.get_child_count()
	gui.set_values(Vector3i(resource_counts))
	if resource_counts.x <= 0 or resource_counts.y <= 0: handle_loss()
	if inhabitants.get_child_count():
		if inhabitants.get_child(0).position.y < 0: inhabitants.get_child(0).take_damage(10000)
		inhabitants.get_child(0).process_world_tick(time)
	
	var bodies: Array = dropzone.get_overlapping_bodies()
	if bodies.size():
		for body in bodies:
			if !body.is_in_group("inhabitant"): continue
			var item = body.remove_item(body.active_slot)
			if item: resource_counts += item.values


func init_village(map, cell_size, spawn_count: int = 3):
	kill_all_inhabitants()
	
	# create inhabitants
	inhabitant_count = spawn_count
	for i in spawn_count:
		# create a new inhabitant in the center of the village
		var inhabitant_name = "krug_"+str(i)
		var new_inhabitant = spawn_inhabitant(inhabitant_name)
		new_inhabitant.init_gui(map, cell_size)
	
	
	# pass control to one of the inhabitents
	posess_next_inhabitant()
	
	# handle resources
	resource_counts = DEFAULT_RESOURCE_COUNTS
	gui.set_values(resource_counts)
	#if !dropzone.body_entered.is_connected(drop_items): dropzone.body_entered.connect(drop_items)


func handle_loss():
	kill_all_inhabitants()
	print("you lose")


# ╭-----------╮
# |   items   |
# ╰-----------╯
func drop_items(body):
	if !body.is_in_group("inhabitant"): return
	for i in 4:
		var item = body.remove_item(i)
		if item: resource_counts += item.values

func drop_active_item(body):
	if !body.is_in_group("inhabitant"): return
	body.remove_item(body.active_slot)
	#for i in 4:
		#var item = body.remove_item(i)
		#if item: resource_counts += item.values


# ╭-----------------╮
# |   inhabitants   |
# ╰-----------------╯
func get_active_inhabitant() -> CharacterBody3D:
	if inhabitants.get_child_count(): return inhabitants.get_child(0)
	else: return null


func posess_next_inhabitant():
	if !inhabitants.get_child_count(): return
	inhabitants.get_child(0).get_child(0).current = true
	inhabitants.get_child(0).show_gui(true)


func kill_all_inhabitants():
	for child in inhabitants.get_children(): child.take_damage(10000)

# rotation
func _unhandled_input(event):
	if event is InputEventMouseMotion and mouse_captured and inhabitants.get_child_count():
		var amount: Vector2 = -event.relative * 0.005
		inhabitants.get_child(0).rotate_inhabitant(amount)


# movement
func _physics_process(delta):
	var input_dir := Vector2.ZERO
	var jump: bool = false
	var sprint: bool = false
	
	if mouse_captured:
		input_dir = Input.get_vector("left", "right", "up", "down")
		if Input.is_action_just_pressed("jump"): jump = true
		if Input.is_action_pressed("sprint"): sprint = true
	
	if inhabitants.get_child_count():
		inhabitants.get_child(0).move_inhabitant(input_dir, jump, sprint, delta)


# mouse capture
func _process(delta):
	if Input.is_action_just_pressed("capture_mouse") or \
	Input.is_action_just_pressed("use") and not mouse_captured:
		mouse_captured = !mouse_captured
		if mouse_captured: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif inhabitants.get_child_count():
		if Input.is_action_just_pressed("interact"):
			inhabitants.get_child(0).interact()
		if Input.is_action_just_pressed("drop_item"):
			inhabitants.get_child(0).drop_item()
		if Input.is_action_just_pressed("scroll_down"):
			inhabitants.get_child(0).scroll()
		elif Input.is_action_just_pressed("scroll_up"):
			inhabitants.get_child(0).scroll(true)


func spawn_inhabitant(inhabitant_name: String = "krug") -> CharacterBody3D:
	var new_inhabitant = INHAB.instantiate()
	new_inhabitant.name = inhabitant_name
	new_inhabitant.position.y += 1.5
	new_inhabitant.position.x += randi_range(-5,5)
	new_inhabitant.position.z += randi_range(-5,5)
	inhabitants.add_child(new_inhabitant)
	
	var handle_take_damage = func(val): 
		print(inhabitant_name, " health: ", val)
		if val <= 0: 
			print(inhabitant_name, " died...")
			handle_inhabitant_death(new_inhabitant)
	
	new_inhabitant.health_changed.connect(handle_take_damage)
	return new_inhabitant


func handle_inhabitant_death(inhabitant: Node3D):
	inhabitant_count -= 1
	
	if !inhabitant_count: handle_loss()
	
	inhabitants.remove_child(inhabitant)
	inhabitant.queue_free()
	posess_next_inhabitant()
