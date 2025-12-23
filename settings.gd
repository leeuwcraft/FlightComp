extends Control

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _draw():
	
	# UDP INDICATORS
	var CondorIndicatorColor = Color(1,0,0)
	var XplaneIndicatorColor = Color(1,0,0)
	if Global.CondorUDPConnection:
		CondorIndicatorColor = Color(0,1,0)
	else:
		CondorIndicatorColor = Color(1,0,0)
	if Global.XPlaneUPDConnection:
		XplaneIndicatorColor = Color(0,1,0)
	else:
		XplaneIndicatorColor = Color(1,0,0)
	
	draw_string(Global.default_font, Vector2(Global.DisplaySize.x/64, Global.DisplaySize.y/8), "XPLANE UDP CONNECTION: " + str(Global.XPlaneUPDConnection))
	draw_string(Global.default_font, Vector2(Global.DisplaySize.x/64, 16+Global.DisplaySize.y/8), "CONDOR UDP CONNECTION: " + str(Global.CondorUDPConnection))
	draw_circle(Vector2(Global.DisplaySize.x/128, -8+Global.DisplaySize.y/8), 2, XplaneIndicatorColor, true)
	draw_circle(Vector2(Global.DisplaySize.x/128, -8+16+Global.DisplaySize.y/8), 2, CondorIndicatorColor, true)
