extends Node


signal send_message( message )

func _ready():
	pass

func log_message(new_message : String):
	emit_signal( "send_message", new_message )

func has_count( string: String ) -> bool:
	if string.rfind( " x" ) != -1:
		var temp = string.split( " x" )
		if temp[1].is_valid_integer():
			return true
	if string.rfind( " x " ) != -1:
		var temp = string.split( " x " )
		if temp[1].is_valid_integer():
			return true
	return false

func split_count( string: String ) -> Array:
	#  return [ item, count ]

	# item x3
	var temp : PoolStringArray = string.split( " x" )
	if temp[1].is_valid_integer():
		return [ temp[0], int(temp[1]) ]
	# item x 3
	temp = string.split( " x " )
	return [ temp[0], int(temp[1]) ]

func remove_count( string: String ) -> String:
	if has_count( string ):
		return split_count( string )[0]
	else:
		return string



func parse_fit( eft_fit : String, include_loaded : bool )-> ship_fit:
	emit_signal( "send_message", "" )
	
	# Make sure yield works
	yield(get_tree(),"idle_frame")
	
	# Replace lower case with uppercases. Easier to support only one way of doing this
	eft_fit = eft_fit.replace ( "[empty high slot]", "[Empty High Slot]" )
	eft_fit = eft_fit.replace ( "[empty med slot]", "[Empty Med Slot]" )
	eft_fit = eft_fit.replace ( "[empty low slot]", "[Empty Low Slot]" )
	eft_fit = eft_fit.replace ( "[empty rig slot]", "[Empty Rig Slot]" )
	eft_fit = eft_fit.replace ( "[empty subsystem slot]", "[Empty Subsystem Slot]" )
	
	var fit_lines : PoolStringArray = eft_fit.split("\n")
	
	if fit_lines[0].length() == 0:
		emit_signal( "send_message", "Error: Invalid input. Empty first line." )
	elif fit_lines[0][0] != "[":
		emit_signal( "send_message", 'Error: No "[name, hull]" on first line.' )
	
	var new_fit : ship_fit = load( "res://classes/ship_fit.gd" ).new()
	
	# First line is [Hull, Name]
	new_fit.hull = fit_lines[0].split( "," )[0].lstrip ( "[" )
	new_fit.fit_name = fit_lines[0].split( "," )[1].rstrip ( "]" )

	# Find what items are in the fit
	# This includes things like [Empty High Slot]
	for index in range(1, fit_lines.size() ):
		var line = fit_lines[index]
		if line.length() == 0:
			# Empty line between high/mid/low/rig/etc.
			continue
		
		if line[0] == "[":
			# Empty slot
			yield( new_fit.add_module( line ), "completed" )
		elif !has_count( line ):
			# It is a module
			var item_and_charge : PoolStringArray = line.split( "," )
			var charge = ""
			if item_and_charge.size() == 2:
				charge = item_and_charge[1].strip_edges()
			
			yield( new_fit.add_module( item_and_charge[0], charge ), "completed" )
			
			if include_loaded and item_and_charge.size() == 2:
				yield( new_fit.add_cargo( item_and_charge[1].strip_edges() ), "completed" )
			
		else:
			# Non module item in cargo
			var item_and_count : Array = split_count( line )
			yield( new_fit.add_cargo( item_and_count[0], item_and_count[1] ), "completed" )

	print( "Fit has been parserd" )
	new_fit.print_fit()
	
	return new_fit
