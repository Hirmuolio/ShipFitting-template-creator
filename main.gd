extends Control

var module_cache = {}
var ship_cache = {}

var work_folder = "user://"
#var work_folder = "/"

onready var output_node = get_node( "HBoxContainer/VBoxContainer3/output" )


func _ready():
	module_cache = load_json(work_folder + "module_cache.json")
	ship_cache = load_json(work_folder + "ship_cache.json")
	pass # Replace with function body.


func load_json(file_path):
	#Get dictionary out of kson file
	#Returns the finished dictionary
	var loaded_file
	var text
	var dictionary
	
	loaded_file = File.new()
	loaded_file.open(file_path, loaded_file.READ)
	text = loaded_file.get_as_text()
	dictionary = parse_json(text)
	loaded_file.close()
	
	if dictionary == null:
		print('ERROR - Failed to load ', file_path)
		return {}
			
	return dictionary


func save_json(file_path, dictionary):
	var file = File.new()
	if file.open(file_path, File.WRITE) != 0:
		print('Error opening file', file_path)
		return

	file.store_line(to_json(dictionary))
	file.close()

func is_high_slot( string ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		return false
	if string in module_cache:
		if module_cache[ string ]["slot"] == "high":
			return true
	else:
		print( "Unknown module in slot determination. Something is broken" )
	return false

func is_med_slot( string ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		return false
	if string in module_cache:
		if module_cache[ string ]["slot"] == "medium":
			return true
	else:
		print( "Unknown module in slot determination. Something is broken" )
	return false

func is_low_slot( string ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		return false
	if string in module_cache:
		if module_cache[ string ]["slot"] == "low":
			return true
	else:
		print( "Unknown module in slot determination. Something is broken" )
	return false

func is_rig_slot( string ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		return false
	if string in module_cache:
		if module_cache[ string ]["slot"] == "rig":
			return true
	else:
		print( "Unknown module in slot determination. Something is broken" )
	return false

func is_drone_slot( string ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		return false
	if string in module_cache:
		if module_cache[ string ]["slot"] == "drone":
			return true
	else:
		print( "Unknown module in slot determination. Something is broken" )
	return false

func has_count( string ):
	if string.rfind( "x" ) != -1:
		var temp = string.split( " x" )
		if temp[1].is_valid_integer():
			return true
	return false

func split_count( string ):
	var temp = string.split( " x" )
	return [ temp[0], int( temp[1] )]
	pass

func remove_count( string ):
	if has_count( string ):
		return split_count( string )[0]
	else:
		return string

func parse_input():
	var eft_node = get_node( "HBoxContainer/VBoxContainer/input" ).get_node( "VBoxContainer/TextEdit" )
	var esi_caller_scene = load( "res://esi calling/esi caller.tscn" )
	var esi_caller = esi_caller_scene.instance()
	add_child( esi_caller )
		
	var linecount = eft_node.get_line_count()
	
	# Get IDs for all the fitted modules
	var item_names = []
	for line in range( linecount ):
		var string = eft_node.get_line ( line )
		if string.length() == 0 or string[0] == "[":
			continue

		if string.find( "," ) != -1:
			print( "loaded module" )
			var string_array = string.rsplit( ", " )
			for charged in string_array:
				var trimmed_name = remove_count( charged )
				if not trimmed_name in item_names and not trimmed_name in module_cache:
					item_names.append( trimmed_name )
		else:
			var trimmed_name = remove_count( string )
			if not trimmed_name in item_names and not trimmed_name in module_cache:
				item_names.append( trimmed_name )
	print( "Modules: " + str(item_names) )
	
	var name_to_id = {}
	if item_names.size() != 0:
		# Get info on the items from ESI
		# Get ID of the items
		var esi_response = yield( esi_caller.get_item_ids( item_names ), "completed" )
		
		if "inventory_types" in esi_response["body"]:
	
			for item in esi_response["body"]["inventory_types"]:
				name_to_id[ item["name"] ] = item["id"]
		
		for item in item_names:
			if not item in name_to_id:
				print( 'Error: Unknonw item "' + item + '" not found in ESI' )
				return
	
	# Get item details.
	if item_names.size() != 0:
		for item_name in item_names:
			var esi_response = yield( esi_caller.get_item_info( name_to_id[item_name] ), "completed" )
			
			var slot
			var dogma_effects = []
			var dogma_attributes = []
			
			if "dogma_effects" in esi_response["body"]:
				for effect in esi_response["body"]["dogma_effects"]:
					dogma_effects.append( effect["effect_id" ] )
			if "dogma_attributes" in esi_response["body"]:
				for effect in esi_response["body"]["dogma_attributes"]:
					dogma_effects.append( effect["attribute_id" ] )
			
			print( dogma_effects )
			
			if 13 in dogma_effects:
				slot = "medium"
			elif 11 in dogma_effects:
				slot = "low"
			elif 12 in dogma_effects:
				slot = "high"
			elif 1272 in dogma_attributes:
				# Drone bandwidth
				slot = "drone"
			elif 1547 in dogma_attributes:
				# Rig size
				slot = "rig"
			else:
				# No good way to separate ammo from other items
				# Everything else goes in cargo anyways so no problem here
				slot = "ammo"
			
			module_cache[ esi_caller.response["body"]["name"] ] = {
				"type_id": esi_caller.response["body"]["type_id"],
				"slot": slot
				}
			#print( esi_caller.response["body"] )
	
	# Find info on the hull
	var hull = eft_node.get_line ( 0 ).split( "," )[0].lstrip ( "[" )
	if not hull in ship_cache:
		var esi_response = yield( esi_caller.get_item_ids( [ hull ] ), "completed" )
		print( esi_response )
		var ship_id = esi_response["body"]["inventory_types"][0]["id"]
		esi_response = yield( esi_caller.get_item_info( ship_id ), "completed" )
		
		var dogma_attributes_dictionary = {}
		for dic in esi_response["body"]["dogma_attributes"]:
			dogma_attributes_dictionary[ dic["attribute_id"] ] = dic["value"]
		
		ship_cache[ hull ] = {
			"type_id": esi_response["body"]["type_id"],
			"high_slots":0,
			"med_slots": 0,
			"low_slots": 0,
			"rig_slots": 0
		}
		# I think ship says it has 0 slots but lets be sure
		print( "Low slots: ", dogma_attributes_dictionary[12] )
		if 12 in dogma_attributes_dictionary:
			ship_cache[ hull ]["low_slots"] = dogma_attributes_dictionary[ 12 ]
		if 13 in dogma_attributes_dictionary:
			ship_cache[ hull ]["med_slots"] = dogma_attributes_dictionary[ 13 ]
		if 14 in dogma_attributes_dictionary:
			ship_cache[ hull ]["high_slots"] = dogma_attributes_dictionary[ 14 ]
		if 1137 in dogma_attributes_dictionary:
			ship_cache[ hull ]["rig_slots"] = dogma_attributes_dictionary[ 1137 ]
	
	save_json(work_folder + "module_cache.json", module_cache)
	save_json(work_folder + "ship_cache.json", ship_cache)
	
	# Convert the input into dictionaries
	
	var high = []
	var high_charge = []
	var high_charge_count = []
	var med = []
	var med_charge = []
	var med_charge_count = []
	var low = []
	var low_charge = []
	var low_charge_count = []
	var rig = []
	var drone = []
	var drone_count = []
	var cargo = []
	var cargo_count = []
	
	#Prepare unfitted json
	print( "low slots: ", ship_cache[ hull ]["low_slots"] )
	for n in range( ship_cache[ hull ]["low_slots"] ):
		low.append( "[Empty Low slot]" )
		low_charge.append( "" )
		low_charge_count.append( 42 )
	for n in range( ship_cache[ hull ]["med_slots"] ):
		med.append( "[Empty Med slot]" )
		med_charge.append( "" )
		med_charge_count.append( 42 )
	for n in range( ship_cache[ hull ]["high_slots"] ):
		high.append( "[Empty High slot]" )
		high_charge.append( "" )
		high_charge_count.append( 42 )
	for n in range( ship_cache[ hull ]["rig_slots"] ):
		rig.append( "[Empty Rig slot]" )
	
	
	var eft_format
	var low_modules = 0
	var med_modules = 0
	var high_modules = 0
	var rigs = 0
	
	for line in range( 1, linecount ):
		var string = eft_node.get_line ( line )
		
		if string.length() == 0:
			continue
		
		var item_name = ""
		var charge = ""
		var count = 1
		
		if string.find( "," ) != -1:
			# Module with charges
			item_name = string.split( ", " )[0]
			var temp_charge = string.split( ", " )[1]
			if has_count( temp_charge ):
				var temp = split_count( temp_charge )
				charge = temp[0]
				count = temp[1]
			else:
				charge = temp_charge
		else:
			if has_count( string ):
				var temp = split_count( string )
				item_name = temp[0]
				count = temp[1]
			else:
				item_name = string
		
		if is_low_slot( item_name ):
			low[ low_modules ] = item_name
			if charge != "":
				low_charge[ low_modules ] = charge
				low_charge_count[ low_modules ] = count
			low_modules += 1
		elif is_med_slot( item_name ):
			med[ med_modules ] = item_name
			if charge != "":
				med_charge[ med_modules ] = charge
				med_charge_count[ med_modules ] = count
			med_modules += 1
		elif is_high_slot( item_name ):
			high[ high_modules ] = item_name
			if charge != "":
				high_charge[ high_modules ] = charge
				high_charge_count[ high_modules ] = count
		elif is_rig_slot( item_name ):
			rig[ rigs ] = item_name
			if charge != "":
				print( "You have charges in your rig?" )
		elif is_drone_slot( item_name ):
			drone.append( item_name )
			drone_count.append( count )
		else:
			cargo.append( item_name )
			cargo_count.append( count )
	
	var fit_name = "asd"
	# Output in wiki template
	var output = ""
	output + "{{ShipFitting\n"
	output + "| ship=" + str(hull) + "\n"
	output + "| shipTypeID="+ str(ship_cache["type_id"]) +  "\n"
	output + "| fitName=" + fit_name + "\n| fitID=" + fit_name + "\n"
	
	output_node.set_contents( output )

func _on_parse_pressed():
	parse_input()
