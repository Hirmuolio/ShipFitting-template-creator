extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var version_info : Dictionary = Engine.get_version_info()
	var version_string = "Godot " + version_info["string"]
	
	set("text", version_string)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
