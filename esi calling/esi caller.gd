extends HTTPRequest

var response : Dictionary = {}

var base_url : String = 'https://esi.evetech.net'

onready var parent_node : Node = get_node("..")

signal send_message( message )

func _ready():
	pass


func retry_error( response_code: int):
	# Return true if the call needs to be done again
	# Return false if call finished properly
	var success_codes : Array = [200, 204, 304, 400, 404]
	var retry_codes : Array = [500, 502, 503, 504] 
	if int(response_code) in retry_codes:
		parent_node.send_message( str( "Error ", response_code, ". Retrying..." ) )
		return true
	elif int(response_code) in success_codes:
		var message : String = str( "Call completed (", response_code, ")." )
		emit_signal("send_message", message )
		return false
	else:
		var message : String = str( "Error ", response_code, ". Call failed." )
		emit_signal("send_message", message )

func get_item_ids( item_array ):
	var keep_trying : bool = true
	var url : String = base_url + "/v1/universe/ids/"
	var headers : Array = ["Content-Type: application/json"]
	var use_ssl : bool = false
	var message : String = "Getting item IDs from ESI..."
	emit_signal("send_message", message )
	
	while keep_trying:
		var _length = request(url, headers, use_ssl, HTTPClient.METHOD_POST, var2str(item_array) )
		yield( self, "request_completed" )
		if not retry_error( response["response_code"] ):
			keep_trying = false
	return response

func get_item_info( item_id : int ):
	var keep_trying : bool = true
	var url : String = base_url + "/v3/universe/types/" + str( item_id ) + "/"
	var message : String = "Getting info on item ID from ESI..."
	emit_signal("send_message", message )
	
	while keep_trying:
		var _length = request(url )
		yield( self, "request_completed" )
		if not retry_error( response["response_code"] ):
				keep_trying = false
	return response

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8() )
	
	response = {}
	response["body"] = json.result
	response["response_code"] = response_code
