tool

extends Control

var contents = false
onready var input_node = get_node( "CheckBox" )
export var label = "" setget set_label

func _ready():
	pass # Replace with function body.


func set_label(new_label):
	label = new_label
	if !has_node('CheckBox'):
        return 
	get_node('CheckBox').set_text(label)
	update()

func _on_CheckBox_pressed():
	contents = !contents
