tool

extends Control

var contents : String = ""
onready var input_node : Node = get_node( "VBoxContainer/TextEdit" )
export var label : String = "" setget set_label
export var show_import : bool = false
export var show_export : bool = false

func _ready():
	if show_import:
		show_import()
	if show_export:
		show_export()


func set_label(new_label : String):
	label = new_label
	if !has_node('VBoxContainer/HBoxContainer/Label'):
		return 
	get_node('VBoxContainer/HBoxContainer/Label').set_text(label)
	update()

func show_import():
	get_node("VBoxContainer/HBoxContainer/import").show()

func show_export():
	get_node("VBoxContainer/HBoxContainer/export").show()

func set_contents( new_contents : String ):
	print( "Contents set" )
	input_node.text = new_contents
	contents = new_contents
	update()

func get_line_count():
	return input_node.get_line_count()

func get_line ( index : int ):
	return input_node.get_line ( index )

func _on_TextEdit_text_changed():
	contents = input_node.text


func _on_import_pressed():
	set_contents( OS.get_clipboard() )


func _on_export_pressed():
	OS.set_clipboard( contents )
