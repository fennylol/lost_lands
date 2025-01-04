extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 15.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const InhabGui = preload("res://inhabitant/inhab_gui/inhab_gui.gd")
@onready var camera: Camera3D = $DEBUG_CAMERA
@onready var hands: Area3D = $DEBUG_CAMERA/HANDS
@onready var GUI: InhabGui = $DEBUG_CAMERA/INHABGUI

const MAX_HEALTH: float = 100
var health: float = MAX_HEALTH
signal health_changed(health: float)


var inventory: Array[Node] = [null,null,null,null]
var inventory_slots: int = inventory.size()
var active_slot: int = 0

# ╭-----------╮
# |   items   |
# ╰-----------╯
func remove_item(slot: int) -> Node:
	var item = inventory[slot]
	inventory[slot] = null
	GUI.clear_inventory_icon(slot)
	if active_slot == slot and hands.get_child_count() > 1:
		hands.remove_child(hands.get_child(1))
		#hands.get_child(1).queue_free()
	return item

func drop_item(slot: int = active_slot):
	var item = remove_item(slot)
	if item: 
		get_tree().root.add_child(item)
		item.position = global_position * Vector3(1,0,1)


func interact():
	# check all nearby bodies, pickup all items
	var nearby_bodies: Array = hands.get_overlapping_areas()
	for i in nearby_bodies.size():
		var item = nearby_bodies[i]
		var item_parent = item.get_parent()
		# if valid item
		if item.is_in_group("item") and hands.get_child_count()-1 < inventory_slots \
		and item_parent.name != hands.name:
			# find open inventory slot
			for slot in inventory_slots:
				if not inventory[active_slot]:
					inventory[active_slot] = item
					item_parent.remove_child(item)
					item.position = Vector3.ZERO
					item.rotation.y += randf_range(0,360)
					GUI.set_inventory_icon(item.get_icon(), active_slot)
					if hands.get_child_count() <= 1: hands.add_child(item) 
					break
				else: scroll()


func scroll(up: bool = false, slot: int = -1):
	if hands.get_child_count() > 1: hands.remove_child(inventory[active_slot])
	if slot != -1: active_slot = slot
	else:
		var dir = 1-int(up)*2
		active_slot = (active_slot+dir+inventory_slots)%inventory_slots
	GUI.set_active_slot(active_slot)
	if inventory[active_slot]: hands.add_child(inventory[active_slot])

func rotate_inhabitant(amount: Vector2):
	rotate_y(amount.x)
	camera.rotate_x(amount.y)
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	GUI.adjust_target_rotation(amount.x)



# ╭--------------╮
# |   movement   |
# ╰--------------╯
func _physics_process(delta):
	if not is_on_floor(): velocity.y -= gravity * delta
	#if not is_on_floor(): velocity.y = max(velocity.y-(gravity * delta),0) 
	
	if is_inside_tree(): move_and_slide()

func move_inhabitant(input_dir: Vector2, jump: bool, sprint: bool, delta: float):
	if jump and is_on_floor(): velocity.y = JUMP_VELOCITY
	#if jump: velocity.y = JUMP_VELOCITY
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * (SPRINT_SPEED if sprint else SPEED)
		velocity.z = direction.z * (SPRINT_SPEED if sprint else SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)



# ╭------------╮
# |   health   |
# ╰------------╯
func take_damage(dmg: float): 
	set_health(health-dmg)


func set_health(val: float):
	health = val
	health_changed.emit(health)



# ╭------------╮
# |    gui     |
# ╰------------╯
func init_gui(map, cell_size):
	show_gui(false)
	GUI.set_minimap(await GUI.tilemap_to_image(map, true), cell_size)
	GUI.update_minimap_display(0)

# gui passthroughs
func process_world_tick(time: Vector4i): GUI.rotate_clock(time)
func new_player_color(): GUI.new_player_color()
func show_gui(show_gui: bool = true): GUI.visible = show_gui
func show_minimap(show_on_gui: bool = true): GUI.show_minimap(show_on_gui)
func show_markers(show_on_gui: bool = true): GUI.show_markers(show_on_gui)
func show_compass(show_on_gui: bool = true): GUI.show_compass(show_on_gui)
func show_clock(show_on_gui: bool = true): GUI.show_clock(show_on_gui)
func get_markers() -> bool: return GUI.markers
