extends Control

var module_cache = {}

var work_folder = "user://"
#var work_folder = "/"


func _ready():
	module_cache = load_json(work_folder + "module_cache.json")
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
		if string.find( "high" ) != -1 or string.find( "High" ) != -1:
			return true
	elif string.find( "," ) != -1:
		# module with charges
		var string_array = string.rsplit( ", " )
		if string_array[0] in module_cache:
			if module_cache[ string_array[0] ]["slot"] == "high":
				return true
		else:
			print( "Unknown module in slot determination. Something is broken" )
	else:
		if string in module_cache:
			if module_cache[ string ]["slot"] == "high":
				return true
		else:
			print( "Unknown module in slot determination. Something is broken" )
	return false

func is_mid_slot( string ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		if string.find( "med" ) != -1 or string.find( "Med" ) != -1:
			print( "Mediums first. This won't work..." )
			return true
	elif string.find( "," ) != -1:
		# module with charges
		var string_array = string.rsplit( ", " )
		if string_array[0] in module_cache:
			if module_cache[ string_array[0] ]["slot"] == "medium":
				print( "Mediums first. This won't work..." )
				return true
		else:
			print( "Unknown module in slot determination. Something is broken" )
	else:
		if string in module_cache:
			if module_cache[ string ]["slot"] == "medium":
				print( "Mediums first. This won't work..." )
				return true
		else:
			print( "Unknown module in slot determination. Something is broken" )
	return false

func is_low_slot( string ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		if string.find( "low" ) != -1 or string.find( "Low" ) != -1:
			return true
	elif string.find( "," ) != -1:
		# module with charges
		var string_array = string.rsplit( ", " )
		if string_array[0] in module_cache:
			if module_cache[ string_array[0] ]["slot"] == "low":
				return true
		else:
			print( "Unknown module in slot determination. Something is broken" )
	else:
		if string in module_cache:
			if module_cache[ string ]["slot"] == "low":
				return true
		else:
			print( "Unknown module in slot determination. Something is broken" )
	return false

func remove_count( string ):
	if string.rfind( "x" ) != -1:
		print( string )
		if string.rfind( "x" ) + 1 < string.length() and string.right( string.rfind( "x" ) + 1 ).is_valid_integer():
			var a = string.rstrip ( "x"+ string.right( string.rfind( "x" ) ) )
			print( string, " ", a )
			return string.rstrip ( "x"+ string.right( string.rfind( "x" ) - 1 ) )
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
	save_json(work_folder + "module_cache.json", module_cache)
	
	# Find which order the input is in (low, mid, high OR high, mid, low)
	var eft_format
	for line in range( 1, linecount ):
		var string = eft_node.get_line ( line )
		var trimmed_name = remove_count( string )
		
		if line > 1 and trimmed_name.length() == 0:
			# The first line after name may be empty. But later empty lines mean end of first grouop
			print( "Unable to determine EFT input format" )
			return
			
		if is_high_slot( trimmed_name ):
			eft_format = 1
			break
		elif is_mid_slot( trimmed_name ):
			# Won't work. Shouldn't happen
			return
		elif is_low_slot( trimmed_name ):
			eft_format = 2
			break
	print( "EFT recognised as format ", str( eft_format ) )
	
	# Convert the input into a JSON

func _on_parse_pressed():
	parse_input()
