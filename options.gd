extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.



func _on_options_pressed():
	show()


func _on_Button_pressed():
	hide()


func _on_website_pressed():
	OS.shell_open("https://github.com/Hirmuolio/ShipFitting-template-creator")
