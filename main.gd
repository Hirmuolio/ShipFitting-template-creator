extends Control

var item_cache = {}

var work_folder = "user://"

onready var output_node : Node = get_node( "HBoxContainer/VBoxContainer3/output" )
onready var name_node : Node = get_node( "HBoxContainer/VBoxContainer2/name" )
onready var id_node : Node = get_node( "HBoxContainer/VBoxContainer2/id" )
onready var date_node : Node = get_node( "HBoxContainer/VBoxContainer2/date" )
onready var difficulty_node : Node = get_node( "HBoxContainer/VBoxContainer2/difficulty" )
onready var alpha_node : Node = get_node( "HBoxContainer/VBoxContainer2/alpha" )
onready var show_skills_node : Node = get_node( "HBoxContainer/VBoxContainer2/show skills" )
onready var show_note_node : Node = get_node( "HBoxContainer/VBoxContainer2/show note" )
onready var show_toc_node : Node = get_node( "HBoxContainer/VBoxContainer2/show TOC" )
onready var notes_node : Node = get_node( "HBoxContainer/VBoxContainer2/notes" )
onready var skills_node : Node = get_node( "HBoxContainer/VBoxContainer2/skills" )
onready var raw_node : Node = get_node( "HBoxContainer/VBoxContainer2/raw" )
onready var eft_node : Node = get_node( "HBoxContainer/VBoxContainer/input" )
onready var ammo_node : Node = get_node( "HBoxContainer/VBoxContainer2/ammo" )
onready var log_node : Node = get_node( "HBoxContainer/VBoxContainer3/TextureRect" )
onready var esi_caller_scene = load( "res://esi calling/esi caller.tscn" )

var abort : bool = false

func _ready():
	item_cache = load_json(work_folder + "item_cache.json")
	
	# Set some defaults
	raw_node.set_state( false )
	ammo_node.set_state( true )
	log_message("Welcome to ShipFitting template importer")

func log_message(new_line: String):
	log_node.add_message(new_line)

func load_json(file_path: String):
	#Get dictionary out of kson file
	#Returns the finished dictionary
	var loaded_file
	var text : String
	var dictionary : Dictionary
	
	loaded_file = File.new()
	loaded_file.open(file_path, loaded_file.READ)
	text = loaded_file.get_as_text()
	dictionary = parse_json(text)
	loaded_file.close()
	
	if dictionary == null:
		log_message( str( 'ERROR - Failed to load ', file_path ) )
		return {}
			
	return dictionary

func save_json(file_path: String, dictionary: Dictionary):
	var file = File.new()
	if file.open(file_path, File.WRITE) != 0:
		log_message( str( 'Error opening file ', file_path ) )
		return

	file.store_line(to_json(dictionary))
	file.close()

func remove_spaces( string: String ):
	while string[0] == " ":
		string = string.trim_prefix( " " )
	while string.ends_with( " " ):
		string = string.trim_suffix( " " )
	return string

func is_high_slot( string: String ):
	if string.length() == 0:
		return true
	if string in [ "[Empty High Slot]", "[empty high slot]" ]:
		return true
	if string in item_cache:
		if item_cache[ string ]["slot"] == "high":
			return true
	else:
		log_message( "Unknown module in slot determination. Something is broken" )
	return false

func is_med_slot( string: String ):
	if string.length() == 0:
		return false
	if string in [ "[Empty Med Slot]", "[empty med slot]" ]:
		return true
	if string in item_cache:
		if item_cache[ string ]["slot"] == "medium":
			return true
	else:
		log_message( "Unknown module in slot determination. Something is broken" )
	return false

func is_low_slot( string: String ):
	if string.length() == 0:
		return false
	if string in [ "[Empty Low Slot]", "[empty low slot]" ]:
		return true
	if string in item_cache:
		if item_cache[ string ]["slot"] == "low":
			return true
	else:
		log_message( "Unknown module in slot determination. Something is broken" )
	return false

func is_rig_slot( string: String ):
	if string.length() == 0:
		return false
	if string in [ "[Empty Rig Slot]", "[empty rig slot]" ]:
		return false
	if string in item_cache:
		if item_cache[ string ]["slot"] == "rig":
			return true
	else:
		log_message( "Unknown module in slot determination. Something is broken" )
	return false

func is_subsystem_slot( string: String ):
	if string.length() == 0:
		return false
	if string in [ "[Empty Subsystem Slot]", "[empty subsystem slot]" ]:
		return true
	if string in item_cache:
		if item_cache[ string ]["slot"] == "subsystem":
			return true
	else:
		log_message( "Unknown module in slot determination. Something is broken" )
	return false

func is_drone_slot( string: String ):
	if string.length() == 0:
		return false
	if string[0] == "[":
		return false
	if string in item_cache:
		if item_cache[ string ]["slot"] == "drone":
			return true
	else:
		log_message( "Unknown module in slot determination. Something is broken" )
	return false

func has_count( string: String ):
	if string.rfind( " x" ) != -1:
		var temp = string.split( " x" )
		if temp[1].is_valid_integer():
			return true
	if string.rfind( " x " ) != -1:
		var temp = string.split( " x " )
		if temp[1].is_valid_integer():
			return true
	return false

func split_count( string: String ):
	# If the input has count return [ item, count ]
	# Else return [ item, 1 ]
	if not has_count( string ):
		return [ string, "1"]
	
	var temp : PoolStringArray = string.split( " x" )
	if temp[1].is_valid_integer():
		return [ temp[0], temp[1]]
	temp = string.split( " x " )
	if temp[1].is_valid_integer():
		return [ temp[0], temp[1]]
	log_message( "Something is broken. This should happen" )

func remove_count( string: String ):
	if has_count( string ):
		return split_count( string )[0]
	else:
		return string

func convert_to_wiki( RichTextLabel_node: Node ):
	var output : String = ""
	var linecount : int = RichTextLabel_node.get_line_count()
	for index in range( linecount ):
		var line : String = RichTextLabel_node.get_line( index )
		output += line + "<br>"
	return output

func convert_to_wiki_list( RichTextLabel_node: Node ):
	var output : String = ""
	var linecount : int = RichTextLabel_node.get_line_count()
	if linecount == 0:
		return output
	output = RichTextLabel_node.get_line ( 0 )
	for index in range( 1, linecount ):
		var line : String = RichTextLabel_node.get_line ( index )
		output += "</li><li>" + line
	return output

func check_input_esi_info( item_names : Array ):
	# Check that all input items are in chache
	# If they are not then get their info from ESI and add to cache
	log_message( "Getting info on the items in the fit" )
	yield(get_tree().create_timer(0.1), "timeout")
	
	var esi_caller = esi_caller_scene.instance()
	add_child( esi_caller )
	
	var reduced_names : Array = []
	
	# Remove items that are already cached
	# Also remove non item things
	for item in item_names:
		if remove_count( item ) in item_cache or item[0] == "[" or remove_count( item ) in reduced_names:
			continue
		reduced_names.append( remove_count( item ) )
	# Also remove duplicates
	
	if reduced_names.size() != 0:
		# Get item IDs
		log_message( str( "Getting info from ESI for items: ", str(reduced_names) ) )
		var esi_response : Dictionary = yield( esi_caller.get_item_ids( reduced_names ), "completed" )
		var name_to_id : Dictionary = {}
		if "inventory_types" in esi_response["body"]:
			for item_response in esi_response["body"]["inventory_types"]:
				name_to_id[ item_response["name"] ] = item_response["id"]
			
			# Check if all items were found in ESI
			for item in reduced_names:
				if not item in name_to_id:
					log_message( str( 'Error: Unknonw item "' + item + '" not found in ESI. This fit may be outdated.' ) )
					abort = true
					return
		else:
			log_message( "Error: Failed to get type ID for any of the items." )
			abort = true
			return
		
		# Get item attributes
		if name_to_id.size() != 0:
			for item in reduced_names:
				esi_response = yield( esi_caller.get_item_info( name_to_id[item] ), "completed" )
				
				var slot : String
				var dogma_effects : Array = []
				var dogma_attributes : Array = []
				
				if "dogma_effects" in esi_response["body"]:
					for effect in esi_response["body"]["dogma_effects"]:
						dogma_effects.append( effect["effect_id" ] )
				if "dogma_attributes" in esi_response["body"]:
					for effect in esi_response["body"]["dogma_attributes"]:
						dogma_attributes.append( effect["attribute_id" ] )
				
				if 13 in dogma_effects:
					slot = "medium"
				elif 11 in dogma_effects:
					slot = "low"
				elif 12 in dogma_effects:
					slot = "high"
				elif float(1366) in dogma_attributes:
					slot = "subsystem"
				elif float(1272) in dogma_attributes:
					# Drone bandwidth
					slot = "drone"
				elif float(1547) in dogma_attributes:
					# Rig size
					slot = "rig"
				else:
					# No good way to separate ammo from other items
					# Everything else goes in cargo anyways so no problem here
					slot = "ammo"
				
				item_cache[ item ] = {
					"type_id": esi_caller.response["body"]["type_id"],
					"slot": slot
					}
	
		save_json(work_folder + "item_cache.json", item_cache)
	
	log_message( "Item info fetching completed" )
	esi_caller.queue_free()

func parse_input():
	abort = false
	var input_node : Node = eft_node.get_node( "VBoxContainer/TextEdit" )
	
	# Check if the input is even somewhat valid
	if eft_node.get_line( 0 ).length() == 0:
		log_message( "Error: Invalid input. Empty first line" )
		return
	elif eft_node.get_line( 0 )[0] != "[":
		log_message( 'Error: No "[name, hull]" on first line' )
		return
	
	# Find what is the hull in the fit
	var hull : String = input_node.get_line ( 0 ).split( "," )[0].lstrip ( "[" )
	
	# Find what items are in the fit
	# This includes things like [Empty High Slot]
	var item_names : Array = []
	var item_counts : Array  = []
	var linecount : int = input_node.get_line_count()
	for index in range( 1, linecount ):
		var line = input_node.get_line ( index )
		if line.length() == 0:
			continue
		if line[0] == "[":
			# Replace lower case with uppercases. Easier to support only one way of doing this
			line = line.replace ( "[empty high slot]", "[Empty High Slot]" )
			line = line.replace ( "[empty med slot]", "[Empty Med Slot]" )
			line = line.replace ( "[empty low slot]", "[Empty Low Slot]" )
			line = line.replace ( "[empty rig slot]", "[Empty Rig Slot]" )
			line = line.replace ( "[empty subsystem slot]", "[Empty Subsystem Slot]" )
		if line.find( "," ) != -1:
			# Module with charges loaded
			var string_array : Array = line.split( "," )
			item_names.append( remove_spaces( string_array[0] ) )
			item_counts.append( "3" )
			
			if ammo_node.contents == true:
				var temp : PoolStringArray = split_count( string_array[1] )
				if not remove_spaces( temp[0] ) in item_names:
					item_names.append( remove_spaces( temp[0] ) )
					item_counts.append( temp[1] )
				else:
					var n : int = item_names.find( remove_spaces( temp[0] ) )
					item_counts[n] = str( int( temp[1] ) + int( item_counts[n] ) )
			#if not remove_count( string_array[1] ) in item_names:
			#	item_names.append( remove_count( string_array[0] ) )
		else:
			var item_and_count : Array = split_count( line )
			item_names.append( remove_spaces( item_and_count[0] ) )
			item_counts.append( item_and_count[1] )
	print( "Items in fit: ", item_names )
	
	yield( check_input_esi_info( item_names ), "completed" )
	
	if abort:
		log_message( 'Unable to process this fit' )
		return
	
	# Convert the input into dictionaries
	
	var high : Array = []
	var med : Array = []
	var low : Array = []
	var subsystem : Array = []
	var rig : Array = []
	var drone : Array = []
	var cargo : Array = []
	
	for n in range( item_names.size() ):
		var item : String = item_names[n]
		if is_high_slot( item ):
			high.append(item)
		elif is_med_slot( item ):
			med.append( item )
		elif is_low_slot( item ):
			low.append( item )
		elif is_rig_slot( item ):
			rig.append( item )
		elif is_subsystem_slot( item ):
			subsystem.append( item )
		elif is_drone_slot( item ):
			drone.append( item + " x" + item_counts[n] )
		else:
			cargo.append( item + " x" + item_counts[n] )
	
	var fit_name : String = eft_node.get_line ( 0 ).split( "," )[1].rstrip ( "]" )
	
	# Output in wiki template
	log_message( 'Assembling  template' )
	var output : String = ""
	
	# Add basic info
	output += "{{ShipFitting\n"
	output += "| ship=" + str(hull) + "\n"
	var export_name : String = fit_name if name_node.contents == "" else name_node.contents
	var export_id : String = export_name if id_node.contents == "" else id_node.contents
	output += "| fitName=" + export_name + "\n| fitID=" + export_id + "\n"
	
	# Add modules
	if high.size() != 0:
		for n in range( high.size() ):
			var index : String = str( n + 1 )
			output += "| high" + index + "name=" + high[n] + "\n"
			if not high[n] in [ "[Empty High Slot]", "[empty high slot]" ]:
				output += "| high" + index + "typeID=" + str( item_cache[ remove_count( high[n] ) ]["type_id"] ) + "\n"
	
	if med.size() != 0:
		for n in range( med.size() ):
			var index : String = str( n + 1 )
			output += "| mid" + index + "name=" + med[n] + "\n"
			if not med[n] in [ "[Empty Med Slot]", "[empty med slot]" ]:
				output += "| mid" + index + "typeID=" + str( item_cache[ remove_count( med[n] ) ]["type_id"] ) + "\n"
	
	if low.size() != 0:
		for n in range( low.size() ):
			var index : String = str( n + 1 )
			output += "| low" + index + "name=" + low[n] + "\n"
			if not low[n] in [ "[Empty Low Slot]", "[empty low slot]" ]:
				output += "| low" + index + "typeID=" + str( item_cache[ remove_count( low[n] ) ]["type_id"] ) + "\n"
	
	if rig.size() != 0:
		for n in range( rig.size() ):
			var index : String = str( n + 1 )
			if not rig[n] in [ "[Empty Rig Slot]", "[empty rig slot]" ]:
				output += "| rig" + index + "name=" + rig[n] + "\n"
				output += "| rig" + index + "typeID=" + str( item_cache[ remove_count( rig[n] ) ]["type_id"] ) + "\n"
	
	if subsystem.size() != 0:
		for n in range( subsystem.size() ):
			var index : String = str( n + 1 )
			if not subsystem[n] in [ "[Empty Subsystem Slot]", "[empty subsystem slot]" ]:
				output += "| subsystem" + index + "name=" + subsystem[n] + "\n"
				output += "| subsystem" + index + "typeID=" + str( item_cache[ remove_count( subsystem[n] ) ]["type_id"] ) + "\n"
	
	if drone.size() != 0:
		for n in range( drone.size() ):
			var index : String = str( n + 1 )
			output += "| drone" + index + "name=" + drone[n] + "\n"
			output += "| drone" + index + "typeID=" + str( item_cache[ remove_count( drone[n] ) ]["type_id"] ) + "\n"
	
	if cargo.size() != 0:
		for n in range( cargo.size() ):
			var index : String = str( n + 1 )
			output += "| charge" + index + "name=" + cargo[n] + "\n"
			output += "| charge" + index + "typeID=" + str( item_cache[ remove_count( cargo[n] )]["type_id"] ) + "\n"
	
	output += "| skills=" + convert_to_wiki_list( skills_node ) + "\n"
	output += "| showSKILLS=" + ( "N\n" if show_skills_node.contents == false else "Y\n" )
	output += "| notes=" + convert_to_wiki_list( notes_node ) + "\n"
	output += "| showNOTES=" + ( "N\n" if show_note_node.contents == false else "Y\n" )
	output += "| difficulty=" + difficulty_node.contents + "\n"
	var version : String = str(OS.get_date()["year"]) + "." + str(OS.get_date()["month"]) + "." + str(OS.get_date()["day"]) if date_node.contents == "" else date_node.contents
	output += "| version=" + version + "\n"
	output += "| showTOC=" + ( "N\n" if show_toc_node.contents == false else "Y\n" )
	output += "| alphacanuse=" + ( "N\n" if alpha_node.contents == false else "Y\n" )
	if raw_node.contents == true:
		output += "| eft fit = " + convert_to_wiki( eft_node )
	output += "}}"
	
	output_node.set_contents( output )
	log_message( 'Template is ready' )

func _on_parse_pressed():
	parse_input()


func _on_clear_pressed():
	eft_node.set_contents( "" )
	output_node.set_contents( "" )
	name_node.set_contents( "" )
	id_node.set_contents( "" )
	date_node.set_contents( "" )
	notes_node.set_contents( "" )
	skills_node.set_contents( "" )
