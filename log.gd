extends TextureRect


onready var log_node = get_node( "log" )


func _ready():
	pass # Replace with function body.


func add_message( message: String ):
	print( message )
	log_node.add_text( "\n" + message )

func clear_log():
	log_node.clear()
