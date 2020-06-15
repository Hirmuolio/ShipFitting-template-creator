extends Node
class_name ship_fit
func get_class(): return "Ship fit"

enum slot { high, medium, low, rig, subsystem, drone, item }
var module_class : Resource = load( "res://classes/module.gd" )

func _ready():
	pass

var fit_name : String = "" setget fit_name_set
var fit_id : String = ""
var hull : String = ""

var high_slots : Array
var medium_slots : Array
var low_slots: Array
var rig_slots : Array
var subsystem_slots : Array
var drone_slots : Array
var cargo_slots : Array

var all_slots : Array setget ,all_slots_get

func fit_name_set( new_name : String ):
	fit_name = new_name
	fit_id = new_name

func add_module( module_name : String, loaded_charge : String = "" ):
	var module : fit_item = module_class.new()
	module.item_name = module_name
	if module_name[0] == "[":
		module.is_item = false
		yield( Utilities.wait_frame(), "completed" )
		return
	
	yield( module.get_stats(), "completed" )
	
	if loaded_charge != "":
		yield( module.add_charge( loaded_charge ), "completed" )
	add_item( module )


func add_cargo( item_name : String, item_count : int  = 1 ):
	
	for item in cargo_slots:
		if item.item_name == item_name:
			item.charge_count += 1
			yield( Utilities.wait_frame(), "completed")
			return
	var module : fit_item = module_class.new()
	module.item_name = item_name
	module.charge_count = item_count
	
	yield( module.get_stats(), "completed" )
	
	cargo_slots.append( module )
	pass

func add_item( new_item : fit_item ):
	if new_item.item_slot == slot.high:
		high_slots.append( new_item )
	elif new_item.item_slot == slot.medium:
		medium_slots.append( new_item )
	elif new_item.item_slot == slot.low:
		low_slots.append( new_item )
	elif new_item.item_slot == slot.rig:
		rig_slots.append( new_item )
	elif new_item.item_slot == slot.subsystem:
		subsystem_slots.append( new_item )
	elif new_item.item_slot == slot.drone:
		drone_slots.append( new_item )
	else:
		cargo_slots.append( new_item )
	

func all_slots_get():
	return high_slots+medium_slots+low_slots+rig_slots+subsystem_slots+drone_slots+cargo_slots

func print_fit():
	print( "High:" )
	for item in high_slots:
		print( item.item_name )
	
	print( "Mid:" )
	for item in medium_slots:
		print( item.item_name )
	
	print( "Low:" )
	for item in low_slots:
		print( item.item_name )
	
	print( "Rig:" )
	for item in rig_slots:
		print( item.item_name )
	
	print( "Subsystem:" )
	for item in subsystem_slots:
		print( item.item_name )
	
	print( "Drone:" )
	for item in drone_slots:
		print( item.item_name )
	
	print( "Cargo:" )
	for item in cargo_slots:
		print( item.item_name )

func clear():
	for item in all_slots_get():
		item.clear()
	queue_free()
