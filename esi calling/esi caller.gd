extends HTTPRequest

var response = {}

var base_url = 'https://esi.evetech.net'

signal call_completed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func remove_spaces( string ):
	while string[0] == " ":
		string = string.trim_prefix( " " )
	while string.ends_with( " " ):
		string = string.trim_suffix( " " )
	return string

func get_item_ids( item_array ):
	var url = base_url + "/v1/universe/ids/"
	var headers = ["Content-Type: application/json"]
	var use_ssl = false
	print( "Calling ESI" )
	request(url, headers, use_ssl, HTTPClient.METHOD_POST, var2str(item_array) )
	yield( self, "request_completed" )
	return response

func get_item_info( item_id ):
	var url = base_url + "/v3/universe/types/" + str( item_id ) + "/"
	print( "Calling ESI" )
	request(url )
	yield( self, "request_completed" )
	return response

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print( "Call completed" )
	var json = JSON.parse(body.get_string_from_utf8() )
	
	response = {}
	response["body"] = json.result
	#response["headers"] = json.result
