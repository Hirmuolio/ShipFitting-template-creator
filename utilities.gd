extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func load_json(file_path: String) -> Dictionary:
	#Get dictionary out of json file
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
		print( str( 'ERROR - Failed to load ', file_path ) )
		return {}
			
	return dictionary

func save_json(file_path: String, dictionary: Dictionary) -> void:
	var file = File.new()
	if file.open(file_path, File.WRITE) != 0:
		print( str( 'Error opening file ', file_path ) )
		return

	file.store_line(to_json(dictionary))
	file.close()

func remove_spaces( string: String ) -> String:
	while string[0] == " ":
		string = string.trim_prefix( " " )
	while string.ends_with( " " ):
		string = string.trim_suffix( " " )
	return string
