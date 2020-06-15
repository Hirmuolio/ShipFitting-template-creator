extends Control

var work_folder = "user://"

onready var output_node : Node = get_node( "HBoxContainer/VBoxContainer3/output" )
onready var name_node : Node = get_node( "HBoxContainer/VBoxContainer2/name" )
onready var id_node : Node = get_node( "HBoxContainer/VBoxContainer2/id" )
onready var date_node : Node = get_node( "HBoxContainer/VBoxContainer2/date" )
onready var difficulty_node : Node = get_node( "HBoxContainer/VBoxContainer2/difficulty" )
onready var alpha_node : Node = get_node( "HBoxContainer/VBoxContainer2/alpha" )
onready var show_skills_node : Node = get_node( "HBoxContainer/VBoxContainer2/show skills" )
onready var show_note_node : Node = get_node( "HBoxContainer/VBoxContainer2/show note" )
onready var show_toc_node : Node = get_node( "HBoxContainer/VBoxContainer2/show TOC" )
onready var notes_node : Node = get_node( "HBoxContainer/VBoxContainer2/notes" )
onready var skills_node : Node = get_node( "HBoxContainer/VBoxContainer2/skills" )
onready var raw_node : Node = get_node( "HBoxContainer/VBoxContainer2/raw" )
onready var eft_node : Node = get_node( "HBoxContainer/VBoxContainer/input" )
onready var ammo_node : Node = get_node( "HBoxContainer/VBoxContainer2/ammo" )
onready var ammo_node2 : Node = get_node( "HBoxContainer/VBoxContainer2/ammo2" )
onready var log_node : Node = get_node( "HBoxContainer/VBoxContainer3/log" )
onready var input_node : Node = eft_node.get_node( "VBoxContainer/TextEdit" )

onready var fit_parser : Node

enum slot { high, medium, low, rig, subsystem, drone, item }

func _ready():
	if OS.get_name() == "HTML5":
		OS.set_low_processor_usage_mode(false)
	
	# Set some defaults
	raw_node.set_state( false )
	ammo_node.set_state( true )
	
	fit_parser = load( "res://fit_parsing/fit_parser.tscn" ).instance()
	add_child( fit_parser )
	
	log_message("Welcome to ShipFitting template importer.")
	
	fit_parser.connect("send_message", self, "log_message")
	DataHandler.connect("send_message", self, "log_message")


func log_message(new_line: String):
	log_node.add_message(new_line)


func convert_to_wiki( RichTextLabel_node: Node ) -> String:
	# Adds <br> to make the lines display right on wiki
	var output : String = ""
	var linecount : int = RichTextLabel_node.get_line_count()
	for index in range( linecount ):
		var line : String = RichTextLabel_node.get_line( index )
		output += line + "<br>"
	return output

func convert_to_wiki_list( RichTextLabel_node: Node ):
	# Converts contents of a rich text label into wiki list
	var output : String = ""
	var linecount : int = RichTextLabel_node.get_line_count()
	if linecount == 0:
		return output
	output = RichTextLabel_node.get_line ( 0 )
	for index in range( 1, linecount ):
		var line : String = RichTextLabel_node.get_line ( index )
		output += "</li><li>" + line
	return output


func item_to_template(item : fit_item, slot_str : String, index : int)->String:
	var output : String
	if item.is_item:
		# | high2name = modulename
		# | high2typeID = 1234
		output += "| "+ slot_str + str(index) + "name=" + item.item_name
		if ammo_node2.contents and item.loaded_charge != null:
			output += ", " + item.loaded_charge.item_name
		if slot_str == "charge":
			output += " x" + str( item.charge_count )
		output += "\n"
		output += "| "+ slot_str + str(index) + "typeID=" + str(item.item_id) + "\n"
	else:
		# Open slot
		output += "| "+ slot_str + str(index) + "name=open\n"
	return output

func check_for_errors( input_fit : ship_fit ):
	var errors : String
	for item in input_fit.all_slots_get():
		if item.item_id == 26902:
			errors += "Invalid item: " + item.item_name + "\n"
	return errors

func fit_to_template( input_fit : ship_fit):
	log_message( 'Assembling  template...' )
	var output : String = ""
	
	# Add basic info
	output += "{{ShipFitting\n"
	output += "| ship=" + input_fit.hull + "\n"
	output += "| fitName=" + input_fit.fit_name + "\n| fitID=" + input_fit.fit_id + "\n"
	
	var index : int = 1
	for item in input_fit.high_slots:
		output += item_to_template(item, "high", index)
		index += 1
	
	index = 1
	for item in input_fit.medium_slots:
		output += item_to_template(item, "mid", index)
		index += 1
	
	index = 1
	for item in input_fit.low_slots:
		output += item_to_template(item, "low", index)
		index += 1
	
	index = 1
	for item in input_fit.rig_slots:
		output += item_to_template(item, "rig", index)
		index += 1
	
	index = 1
	for item in input_fit.subsystem_slots:
		output += item_to_template(item, "subsystem", index)
		index += 1
	
	index = 1
	for item in input_fit.drone_slots:
		output += item_to_template(item, "drone", index)
		index += 1
	
	index = 1
	for item in input_fit.cargo_slots:
		output += item_to_template(item, "charge", index)
		index += 1
	
	
	output += "| skills=" + convert_to_wiki_list( skills_node ) + "\n"
	output += "| showSKILLS=" + ( "N\n" if show_skills_node.contents == false else "Y\n" )
	output += "| notes=" + convert_to_wiki_list( notes_node ) + "\n"
	output += "| showNOTES=" + ( "N\n" if show_note_node.contents == false else "Y\n" )
	output += "| difficulty=" + difficulty_node.contents + "\n"
	var version : String = str(OS.get_date()["year"]) + "." + str(OS.get_date()["month"]) + "." + str(OS.get_date()["day"]) if date_node.contents == "" else date_node.contents
	output += "| version=" + version + "\n"
	output += "| showTOC=" + ( "N\n" if show_toc_node.contents == false else "Y\n" )
	output += "| alphacanuse=" + ( "N\n" if alpha_node.contents == false else "Y\n" )
	if raw_node.contents == true:
		output += "| eft fit = " + convert_to_wiki( eft_node )
	output += "}}"
	
	var errors: String = check_for_errors( input_fit )
	if errors.length() != 0:
		log_message( "There were some errors:\n" + errors )
	return output


func parse_input():
	var include_loaded_charges : bool = ammo_node.contents
	var input_fit : ship_fit = yield( fit_parser.parse_fit( input_node.text, include_loaded_charges ), "completed" )
	var wiki_template = fit_to_template( input_fit )
	output_node.set_contents( wiki_template )
	log_message( 'Template is ready.' )
	input_fit.clear()
	#yield(get_tree(),"idle_frame")


func _on_parse_pressed():
	parse_input()


func _on_clear_pressed():
	eft_node.set_contents( "" )
	output_node.set_contents( "" )
	name_node.set_contents( "" )
	id_node.set_contents( "" )
	date_node.set_contents( "" )
	notes_node.set_contents( "" )
	skills_node.set_contents( "" )


func _on_clear_cache_pressed():
	DataHandler.clear_cache()
