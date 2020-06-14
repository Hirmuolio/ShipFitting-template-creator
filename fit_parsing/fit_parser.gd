extends Node


#var main_node : Node
signal send_message( message )

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func is_high_slot( string: String ) -> bool:
	if string.length() == 0:
		return true
	if string in [ "[Empty High Slot]", "[empty high slot]" ]:
		return true
	if string in DataHandler.item_cache:
		if DataHandler.item_cache[ string ]["slot"] == "high":
			return true
	else:
		pass
		emit_signal("send_message", "Unknown module in slot determination. Something is broken." )
	return false

func is_med_slot( string: String ) -> bool:
	if string.length() == 0:
		return false
	if string in [ "[Empty Med Slot]", "[empty med slot]" ]:
		return true
	if string in DataHandler.item_cache:
		if DataHandler.item_cache[ string ]["slot"] == "medium":
			return true
	else:
		pass
		emit_signal("send_message", "Unknown module in slot determination. Something is broken." )
	return false

func is_low_slot( string: String ) -> bool:
	if string.length() == 0:
		return false
	if string in [ "[Empty Low Slot]", "[empty low slot]" ]:
		return true
	if string in DataHandler.item_cache:
		if DataHandler.item_cache[ string ]["slot"] == "low":
			return true
	else:
		pass
		emit_signal("send_message", "Unknown module in slot determination. Something is broken." )
	return false

func is_rig_slot( string: String ) -> bool:
	if string.length() == 0:
		return false
	if string in [ "[Empty Rig Slot]", "[empty rig slot]" ]:
		return false
	if string in DataHandler.item_cache:
		if DataHandler.item_cache[ string ]["slot"] == "rig":
			return true
	else:
		pass
		emit_signal("send_message", "Unknown module in slot determination. Something is broken." )
	return false

func is_subsystem_slot( string: String ) -> bool:
	if string.length() == 0:
		return false
	if string in [ "[Empty Subsystem Slot]", "[empty subsystem slot]" ]:
		return true
	if string in DataHandler.item_cache:
		if DataHandler.item_cache[ string ]["slot"] == "subsystem":
			return true
	else:
		pass
		emit_signal("send_message", "Unknown module in slot determination. Something is broken." )
	return false

func is_drone_slot( string: String ) -> bool:
	if string.length() == 0:
		return false
	if string[0] == "[":
		return false
	if string in DataHandler.item_cache:
		if DataHandler.item_cache[ string ]["slot"] == "drone":
			return true
	else:
		pass
		emit_signal("send_message", "Unknown module in slot determination. Something is broken." )
	return false

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
	# If the input has count return [ item, count ]
	# Else return [ item, 1 ]
	if not has_count( string ):
		return [ string, "1"]
	
	# item x3
	var temp : PoolStringArray = string.split( " x" )
	if temp[1].is_valid_integer():
		return [ temp[0], temp[1]]
	# item x 3
	temp = string.split( " x " )
	if temp[1].is_valid_integer():
		return [ temp[0], temp[1]]
	# Something unknown
	else:
		return [ string, "1"]

func remove_count( string: String ) -> String:
	if has_count( string ):
		return split_count( string )[0]
	else:
		return string
