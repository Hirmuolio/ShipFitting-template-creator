tool

extends Control

var contents = "0"
onready var input_node = get_node( "HBoxContainer/OptionButton" )
export var label = "" setget set_label

func _ready():
	var difficulties = [0, 1, 2]
	input_node.clear()
	for diff in difficulties:
		input_node.add_item ( str(diff), diff )
	pass # Replace with function body.


func set_label(new_label):
	label = new_label
	if !has_node('HBoxContainer/Label'):
        return 
	get_node('HBoxContainer/Label').set_text(label)
	update()


func _on_OptionButton_item_selected(ID):
	contents = str(ID)
