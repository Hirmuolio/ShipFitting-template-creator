tool

extends Control

var contents = ""
onready var input_node = get_node( "HBoxContainer/LineEdit" )
export var label = "" setget set_label

func _ready():
	pass # Replace with function body.


func set_label(new_label):
	label = new_label
	if !has_node('HBoxContainer/Label'):
		return 
	get_node('HBoxContainer/Label').set_text(label)
	update()

func set_contents( new_contents ):
	contents = new_contents
	input_node.text = new_contents

func _on_LineEdit_text_changed(new_text):
	contents = new_text
