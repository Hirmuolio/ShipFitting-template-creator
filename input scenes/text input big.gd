tool

extends Control

var contents = ""
onready var input_node = get_node( "VBoxContainer/TextEdit" )
export var label = "" setget set_label

func _ready():
	pass # Replace with function body.


func set_label(new_label):
	label = new_label
	if !has_node('VBoxContainer/Label'):
        return 
	get_node('VBoxContainer/Label').set_text(label)
	update()

func _on_TextEdit_text_changed():
	contents = input_node.text
