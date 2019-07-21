extends HTTPRequest

var response = {}

var base_url = 'https://esi.evetech.net'

signal call_completed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func test0():
	print( "0 starts" )
	test1()
	print( "0 end" )

func test1():
	print( "1 start" )
	var test_ret = yield(test2(), "completed")
	print( test_ret )
	print( "1 end" )
	
	pass

func test2():
	print( "2 start" )
	yield(get_tree().create_timer(2), "timeout")
	print( "2 end" )
	#emit_signal( "call_completed" )
	return 2


func get_item_ids( item_array ):
	var url = base_url + "/v1/universe/ids/"
	var headers = ["Content-Type: application/json"]
	var use_ssl = false
	request(url, headers, use_ssl, HTTPClient.METHOD_POST, var2str(item_array) )
	yield( self, "request_completed" )
	return response

func get_item_info( item_id ):
	var url = base_url + "/v3/universe/types/" + str( item_id ) + "/"
	print( url )
	request(url )
	yield( self, "request_completed" )
	return response

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print( "Call completed" )
	var json = JSON.parse(body.get_string_from_utf8() )
	
	response = {}
	response["body"] = json.result
	#response["headers"] = json.result
