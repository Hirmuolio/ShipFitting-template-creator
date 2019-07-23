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

func retry_error( response_code ):
	# Return true if the call needs to be done again
	# Return false if call finished properly
	var success_codes = [200, 204, 304, 400, 404]
	var retry_codes = [500, 502, 503, 504] 
	if int(response_code) in retry_codes:
		print( "Error ", response_code, ". Retrying..." )
		return true
	elif int(response_code) in success_codes:
		print( "Call completed (", response_code, ")" )
		return false
	else:
		print( "Error ", response_code, ". Call failed." )

func get_item_ids( item_array ):
	var keep_trying = true
	var url = base_url + "/v1/universe/ids/"
	var headers = ["Content-Type: application/json"]
	var use_ssl = false
	print( "Calling ESI..." )
	
	while keep_trying:
		request(url, headers, use_ssl, HTTPClient.METHOD_POST, var2str(item_array) )
		yield( self, "request_completed" )
		if not retry_error( response["response_code"] ):
			keep_trying = false
	return response

func get_item_info( item_id ):
	var keep_trying = true
	var url = base_url + "/v3/universe/types/" + str( item_id ) + "/"
	print( "Calling ESI..." )
	
	while keep_trying:
		request(url )
		yield( self, "request_completed" )
		if not retry_error( response["response_code"] ):
				keep_trying = false
	return response

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8() )
	
	response = {}
	response["body"] = json.result
	response["response_code"] = response_code