extends Node2D
	
func _ready() -> void:
	
	var versionlabel = Label.new()
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(300, 1000)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.position = Vector2(Global.DisplayCenter.x-300/2, Global.DisplayCenter.y)
	label.text = "This tool is intended solely as a secondary VFR flight aid. It is not certified for, nor intended to be used as, a primary means of navigation. Pilots must rely on approved charts, instruments, and visual references at all times."
	
	versionlabel.text = ProjectSettings.get_setting("application/config/version")
	add_child(label)
	add_child(versionlabel)

func _process(delta: float) -> void:
	$TextureRect.size = Global.DisplaySize
	$Sprite2D.position = Global.DisplayCenter
	var ElapsedTime = Time.get_ticks_msec()
	if ElapsedTime > 3000:
		get_tree().change_scene_to_file("res://scenes/main menu.tscn")
		Global.playSound(load("res://sounds/bubble-pop-389501.mp3"),0.5)
