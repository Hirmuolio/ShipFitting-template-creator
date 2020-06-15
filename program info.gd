extends Label



func _ready():
	var version_info : Dictionary = Engine.get_version_info()
	var version_string = "Godot " + version_info["string"]
	
	set("text", version_string)
	pass # Replace with function body.

