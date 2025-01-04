extends VBoxContainer

var EMPTY = preload("res://item/_resources/empty_icon.png")
var ACTIVE = preload("res://item/_resources/slot.png")
var INACTIVE = preload("res://item/_resources/slot_inactive.png")
@onready var inventory = [$inventory/SLOT_0,$inventory/SLOT_1,$inventory/SLOT_2,$inventory/SLOT_3]

func _ready():
	var adjust_sizing = func():
		var size = get_viewport_rect().size.y * 0.2
		var inv = $inventory
		inv.custom_minimum_size.y = size
		inv.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	adjust_sizing.call()
	get_tree().root.size_changed.connect(adjust_sizing)



func set_inventory_icon(icon: ImageTexture, slot: int):
	inventory[slot].texture = icon

func clear_inventory_icon(slot: int):
	inventory[slot].texture = EMPTY

func set_active_slot(slot: int): 
	for i in inventory.size():
		var img = ACTIVE if slot == i else INACTIVE
		var child = inventory[i].get_child(0)
		child.texture = ImageTexture.create_from_image(img)

#func set_inventory_slot_count(count: int = 4):
	#var inven = $inventory
	#const slot_scene = preload("res://inhabitant/slot.tscn")
	#
	#var end_spacer = $inventory/end_spacer
	#var mid_spacer = $inventory/spacer
	#
	#for i in count:
		#var slot = slot_scene.instantiate()
		#slot.name = "SLOT_" + str(i)
		#inven.add_child(slot)
		#if i != count-1: inven.add_child(mid_spacer.duplicate())
		#inventory.push_back(slot)
		#inven.move_child(end_spacer, inven.get_child_count()-1)

