extends CharacterBody3D


@export var wish_dir := Vector3.ZERO
#var walk_speed := 2.0
#var sprint_speed := 8.5
#var ground_accel := 20.0
#var ground_decel := 7.0
#var ground_friction := 3.5
#var air_cap := 0.85 # Can surf steeper ramps if this is higher, makes it easier to stick and bhop
#var air_accel := 800.0
#var air_move_speed := 500.0
const JUMP_VELOCITY := 6
const PUSH_FORCE := 0.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const InhabGui = preload("res://inhabitant/inhab_gui/inhab_gui.gd")
@onready var camera: Camera3D = $DEBUG_CAMERA
@onready var hands: Area3D = $DEBUG_CAMERA/HANDS
@onready var GUI: InhabGui = $DEBUG_CAMERA/INHABGUI

const MAX_HEALTH: float = 100
var health: float = MAX_HEALTH
signal health_changed(health: float)
signal dead()

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
	var item: RigidBody3D = remove_item(slot)
	if item: 
		get_tree().root.add_child(item)
		item.freeze = false
		item.collision_layer += DATA.LAYERS.ITEM
		item.linear_velocity = velocity*1.3
		item.angular_velocity = velocity*0.25
		item.position = to_global(Vector3(0,0,0-1))
		#item.set_mesh_scale()

func pickup_item(item: RigidBody3D):
	inventory[active_slot] = item
	var rot = item.global_rotation
	item.get_parent().remove_child(item)
	#item.set_mesh_scale(item.hand_scale)
	item.position = Vector3.ZERO
	item.freeze = true
	item.collision_layer -= DATA.LAYERS.ITEM
	GUI.set_inventory_icon(item.get_icon(), active_slot)
	if hands.get_child_count() <= 1: 
		hands.add_child(item) 
		item.global_rotation = rot


func interact():
	# check all nearby bodies, pickup all items
	var nearby_bodies: Array = hands.get_overlapping_bodies()
	for i in nearby_bodies.size():
		var item = nearby_bodies[i]
		var item_parent = item.get_parent()
		# if valid item
		if item.is_in_group("item") and hands.get_child_count()-1 < inventory_slots \
		and item_parent.name != hands.name:
			# find open inventory slot
			for slot in inventory_slots:
				if not inventory[active_slot]:
					pickup_item(item)
					break
				else: scroll()


func scroll(up: bool = false, slot: int = -1) -> String:
	if inventory[active_slot]: if inventory[active_slot].is_large: return "HANDS FULL"
	if hands.get_child_count() > 1: hands.remove_child(inventory[active_slot])
	if slot != -1: active_slot = slot
	else:
		var dir = 1-int(up)*2
		active_slot = (active_slot+dir+inventory_slots)%inventory_slots
	GUI.set_active_slot(active_slot)
	if inventory[active_slot]: 
		hands.add_child(inventory[active_slot])
		return inventory[active_slot].name.split("_")[0]
	return ""





# ╭------------╮
# |   health   |
# ╰------------╯
func take_damage(dmg: float): 
	set_health(health-dmg)



func set_health(val: float):
	health = val
	health_changed.emit(health)
	GUI.set_health(health)
	if health <= 0: handle_death()

func handle_death():
	for i in inventory_slots: drop_item(i)
	dead.emit()
	queue_free()


# ╭------------╮
# |    gui     |
# ╰------------╯
func init_gui(map, cell_size):
	show_gui(false)
	GUI.set_minimap(await GUI.tilemap_to_image(map, true), cell_size)
	GUI.update_minimap_display(0)
	GUI.set_max_health(MAX_HEALTH)
	GUI.set_health(health)

# gui passthroughs
func process_world_tick(time: Vector4i): GUI.rotate_clock(time)
func new_player_color(): GUI.new_player_color()
func show_gui(show_gui: bool = true): GUI.visible = show_gui
func show_minimap(show_on_gui: bool = true): GUI.show_minimap(show_on_gui)
func show_markers(show_on_gui: bool = true): GUI.show_markers(show_on_gui)
func show_compass(show_on_gui: bool = true): GUI.show_compass(show_on_gui)
func show_clock(show_on_gui: bool = true): GUI.show_clock(show_on_gui)
func show_light(show_light: bool = true): $DEBUG_CAMERA/SpotLight3D.visible = show_light # not technically gui but whatever
func get_markers() -> bool: return GUI.markers



# ╭--------------╮
# |   movement   |
# ╰--------------╯
# stolen from https://github.com/majikayogames/SimpleFPSController
# https://www.youtube.com/@MajikayoGames
func _physics_process(delta):
	if is_on_floor(): _handle_ground_physics(delta)
	else: _handle_air_physics(delta)
	
	if is_inside_tree(): 
		move_and_slide()
		
		# push stuff
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody3D:
				c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)


func handle_inputs(input_dir: Vector2, jump: bool):
	if jump and is_on_floor(): velocity.y = JUMP_VELOCITY
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)


func rotate_inhabitant(amount: Vector2):
	rotate_y(amount.x)
	camera.rotate_x(amount.y)
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	GUI.adjust_target_rotation(amount.x)

func get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

var walk_speed := 7.0
var sprint_speed := 8.5
var ground_accel := 20.0
var ground_decel := 7.0
var ground_friction := 3.5
func _handle_ground_physics(delta) -> void:
	# Similar to the air movement. Acceleration and friction on ground.
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	# Apply friction
	var control = max(self.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed

@export var air_cap := 5 # Can surf steeper ramps if this is higher, makes it easier to stick and bhop
@export var air_accel := 80.0
@export var air_move_speed := 5
func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# Classic battle tested & fan favorite source/quake air movement recipe.
	# CSS players gonna feel their gamer instincts kick in with this one
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	# Wish speed (if wish_dir > 0 length) capped to air_cap
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	# How much to get to the speed the player wishes (in the new dir)
	# Notice this allows for infinite speed. If wish_dir is perpendicular, we always need to add velocity
	#  no matter how fast we're going. This is what allows for things like bhop in CSS & Quake.
	# Also happens to just give some very nice feeling movement & responsiveness when in the air.
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta # Usually is adding this one.
		accel_speed = min(accel_speed, add_speed_till_cap) # Works ok without this but sticking to the recipe
		self.velocity += accel_speed * wish_dir
	
	if is_on_wall():
		# The floating mode is much better and less jittery for surf
		# This bit of code is tricky. Will toggle floating mode in air
		# is_on_floor() never triggers in floating mode, and instead is_on_wall() does.
		if is_surface_too_steep(get_wall_normal()):
			self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_wall_normal(), 1, delta) # Allows surf

func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func clip_velocity(normal: Vector3, overbounce : float, _delta : float) -> void:
	# When strafing into wall, + gravity, velocity will be pointing much in the opposite direction of the normal
	# So with this code, we will back up and off of the wall, cancelling out our strafe + gravity, allowing surf.
	var backoff := self.velocity.dot(normal) * overbounce
	# Not in original recipe. Maybe because of the ordering of the loop, in original source it
	# shouldn't be the case that velocity can be away away from plane while also colliding.
	# Without this, it's possible to get stuck in ceilings
	if backoff >= 0: return
	
	var change := normal * backoff
	self.velocity -= change
	
	# Second iteration to make sure not still moving through plane
	# Not sure why this is necessary but it was in the original recipe so keeping it.
	var adjust := self.velocity.dot(normal)
	if adjust < 0.0:
		self.velocity -= normal * adjust





