extends Control

var grid = GridContainer.new()

#init default state for debug
var DataDic : PackedStringArray
var buttonCount = 10

func _ready() -> void:
	#init grid structure and buttons
	grid.columns = 1
	grid.position = Vector2(100,100)
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	add_child(grid)
	for i in buttonCount:
		var label = Label.new()
		label.text = ""
		grid.add_child(label)


func _process(_delta: float) -> void:
	#UPDATE DEBUG
	DataDic = [
	"Airspeed IAS: "+ str(Global.airspeedKTS),
	"Altitude MSL: "+ str(Global.altitudeM),
	"G-force: "+ str(Global.g_force),
	"heading: "+ str(Global.heading),
	"Latitude: "+ str(Global.latitude),
	"Longtitude: "+ str(Global.longtitude),
	"CurrentWaypoint: "+ str(Global.CurrentWaypoint),	
	"distance to waypoint: "+str(Global.DistToWaypoint),
	"Total Energy: "+ str(Global.TE),
	"Vario: "+str(Global.TEVario),
	]
	for i in grid.get_child_count():
		if i < buttonCount:
			grid.get_child(i).text = str(DataDic[i])
	
