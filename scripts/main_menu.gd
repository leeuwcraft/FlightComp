extends Control

var grid = GridContainer.new()
var buttoncount = DirAccess.open("res://scenes/").get_files()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	add_child(grid)
	for i in buttoncount:
		if i.split(".")[1] == "tscn" and i.split(".")[0] != "main menu":
			var button = Button.new()
			button.custom_minimum_size = Vector2(Global.DisplaySize.x/3, Global.DisplaySize.y/8)
			button.text = i.split(".")[0]
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			button.pressed.connect(_on_Button_pressed.bind(i.split(".")[0]))
			grid.add_child(button)

func _on_Button_pressed(scene_to_load):
	get_tree().change_scene_to_file("res://scenes/" + scene_to_load + ".tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
