extends Node
class_name fit_item
func get_class(): return "Fit item"

enum slot { high, medium, low, rig, subsystem, drone, item }

func _ready():
	pass

#Main attributes
var item_name : String
var is_item : bool = true

# Extra things from the EFT import
var loaded_charge : fit_item
var charge_count : int

# Stats from ESI
var item_id : int
var item_slot : int

func get_stats():
	print( "Getting item stats: ", item_name)
	item_id = yield( DataHandler.get_item_id( item_name ), "completed" )
	var stats : Dictionary = yield( DataHandler.get_item_stats( item_id ), "completed" )
	
	item_slot = get_slot( stats )
	print( item_name, "done")


func get_slot( stats : Dictionary) -> int:
	print( "Getting item slot")
	#enum { high, medium, low, rig, subsystem, drone, item }
	
	var dogma_effects : Array = []
	var dogma_attributes : Array = []
	
	if "dogma_effects" in stats:
		for effect in stats["dogma_effects"]:
			dogma_effects.append( effect["effect_id" ] )
	if "dogma_attributes" in stats:
		for effect in stats["dogma_attributes"]:
			dogma_attributes.append( effect["attribute_id" ] )
	
	if 13 in dogma_effects:
		# 13 = Requires a medium power slot
		return slot.medium
	elif 11 in dogma_effects:
		# 11 = Requires a low power slot
		return slot.low
	elif 12 in dogma_effects:
		# 12 = Requires a high power slot
		return slot.high
	elif float(1366) in dogma_attributes:
		# 1366 = subSystemSlot
		return slot.subsystem
	elif float(1272) in dogma_attributes:
		# 1272 = Drone bandwidth
		return slot.drone
	elif float(1547) in dogma_attributes:
		# 1547 = Rig size
		return slot.rig
	else:
		# No good way to separate ammo from other items
		# Everything else goes in cargo anyways so no problem here
		return slot.item

func add_charge( charge_name : String ):
	var item : fit_item = load( "res://classes/module.gd" ).new()
	loaded_charge = item
	item.item_name = charge_name
	loaded_charge.charge_count = 1
	yield( item.get_stats(), "completed" )
