@tool
extends Node3D

@onready var camera = $aircraft/pivot/Camera3D
@onready var pivot = $aircraft/pivot
@onready var aircraft = $aircraft
@onready var horizonline = $"aircraft/horizon line"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#aircraft.position.x = Global.latitude * 111.132 #convert to meters
	#aircraft.position.z = Global.longtitude * 111.132
	aircraft.position.y = Global.altitudeM
	
	camera.rotation.x = deg_to_rad(Global.pitch)
	camera.rotation.z = deg_to_rad(-Global.roll)
	pivot.rotation.y = deg_to_rad(-Global.heading)
	
