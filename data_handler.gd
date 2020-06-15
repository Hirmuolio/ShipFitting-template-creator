extends Node

signal send_message( message )

var esi_caller_scene = preload( "res://esi calling/esi calling.tscn" )

var work_folder = "user://"

var item_cache : Dictionary = {}
var names_cache : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	item_cache = Utilities.load_json(work_folder + "item_cache.json")
	names_cache = Utilities.load_json(work_folder + "names_cache.json")

func log_message(new_message : String):
	emit_signal( "send_message", new_message )

func get_item_id( item_name : String ) -> int:
	if item_name in names_cache:
		yield(get_tree(),"idle_frame")
		return names_cache[item_name]
	
	var url = "/v1/universe/ids/"
	var payload = '["' + item_name + '"]'
	var esi_caller = esi_caller_scene.instance()
	add_child(esi_caller)
	esi_caller.connect("send_message", self, "log_message")
	var response = yield( esi_caller.call_esi( url, payload, HTTPClient.METHOD_POST ), "completed" )
	esi_caller.queue_free()
	
	if response["response_code"] != 200:
		# This id is bad. Shouldn't happen ever but lets check anyways.
		print( "Something is very broken. getting name ", response["response_code"] )
		return 0
	# Response is dictionary with array with dictionary
	var item_id = response["response"].result["inventory_types"][0]["id"]
	names_cache[item_name] = item_id
	Utilities.save_json(work_folder + "names_cache.json", names_cache)
	
	return item_id


func get_item_stats( item_id : int ) -> Dictionary:
	if str( item_id ) in item_cache:
		yield(get_tree(),"idle_frame")
		return item_cache[ str( item_id ) ]
	
	var url : String = "/v3/universe/types/" + str(item_id) + "/"
	var esi_caller = esi_caller_scene.instance()
	add_child(esi_caller)
	esi_caller.connect("send_message", self, "log_message")
	var response = yield( esi_caller.call_esi( url ), "completed" )
	esi_caller.queue_free()
	
	if response["response_code"] != 200:
		# This id is bad. Shouldn't happen ever but lets check anyways.
		print( "Something is very broken. getting stats ", response["response_code"] )
		return {}
	item_cache[ str( item_id ) ] = response["response"].result
	Utilities.save_json(work_folder + "item_cache.json", item_cache)
	
	return response["response"].result
