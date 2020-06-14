extends Node

var work_folder = "user://"

var item_cache : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	item_cache = Utilities.load_json(work_folder + "item_cache.json")


