extends Node2D
var MenuBoxY = 0.9

var MenuBox : PackedVector2Array = ([
		Vector2(0,Global.DisplaySize.y),
		Vector2(Global.DisplaySize.x,Global.DisplaySize.y),
		Vector2(Global.DisplaySize.x,Global.DisplaySize.y*MenuBoxY),
		Vector2(0,Global.DisplaySize.y*MenuBoxY),
])

var home = Button.new()
var HorizonButton = Button.new()
var MapButton = Button.new()

func _init() -> void:
	
	home.text = "HOME"
	home.custom_minimum_size = Vector2(Global.DisplaySize.x/8, Global.DisplaySize.y/16)
	home.pressed.connect(GotoHome.bind())
	
func GotoHome():
	Global.playSound(load("res://sounds/ui-sounds-pack-5-2-359749.mp3"), 1)
	get_tree().change_scene_to_file("res://scenes/main menu.tscn")

func UpdatePackedArrays():
	MenuBox = ([
		Vector2(0,Global.DisplaySize.y),
		Vector2(Global.DisplaySize.x,Global.DisplaySize.y),
		Vector2(Global.DisplaySize.x,Global.DisplaySize.y*MenuBoxY),
		Vector2(0,Global.DisplaySize.y*MenuBoxY),
])

func _process(_delta):
	UpdatePackedArrays()

func _draw():
	draw_polygon(MenuBox, [Global.background])
	add_child(home)
