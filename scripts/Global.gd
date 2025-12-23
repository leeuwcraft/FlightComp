extends Node2D

var XplaneUDP = PacketPeerUDP.new()
var CondorUDP = PacketPeerUDP.new()

#settings
var smoothing = 0.2
var DoubleTapThreshold = 0.3
var lastTapTime = 0
var OnlineMode : bool = false

var mainMenuScene = load("res://scenes/main_menu.tscn")
var DisplaySize = DisplayServer.window_get_size()
var DisplayCenter = DisplayServer.window_get_size()/2
var default_font : Font = ThemeDB.fallback_font;
var MobileMode : bool = false

#textures
var Aircraft_texture = Image.load_from_file("res://textures/plane.png")
var Aircraft_texture_small = ImageTexture.create_from_image(Aircraft_texture)

#files

#XplaneUDP variables
var UPDConnection = false
var XPlaneUPDConnection = false
var CondorUDPConnection = false

var pitch = 0 #deg
var roll = 0 #deg
var heading = 0 #deg

var altitudeM = 0 #meter
var airspeedKTS = 0 #knots
var airspeedKMH = 0 #kilometer/h

var g_force = 0 #Gs

var longtitude = 0 #X
var latitude = 0 #Y
var CurrentWaypoint = ""
var DistToWaypoint = 0

var Mass = 500 #kg
var TE = 0 #total energy Joules
var TEVario = 0
var TETable = []
var TETableSum = 0

#colors
var sky_color_top = Color(0.6, 0.9, 1.0)
var sky_color_bottom = Color(0.2, 0.5, 0.9)
var ground_color_top = Color(0.6, 0.4, 0.2)
var orange = Color(1,0.6,0.4)
var ground_color_bottom = Color(0.1, 0.1, 0.05)
var yellow = Color(0.7,0.7,0.1)
var dark_yellow = Color(0.4,0.4,0.05)
var white_color = Color(1,1,1)
var background = Color(0.1, 0.1, 0.1)
var background_transparent = Color(0.1, 0.1, 0.1, 0.4)

var draw_requests = []

func CalculateDistance(delta):
	var latT = deg_to_rad(6.216981358384821)
	var lonT = deg_to_rad(51.36342429859314)
	var latC = deg_to_rad(latitude)
	var lonC = deg_to_rad(longtitude)
	
	var r = 6371000
	var d = 2*r*asin(sqrt(sin((latT-latC)/2)**2 + cos(latC) * cos(latT) * sin((lonT-lonC)/2)**2))	
	DistToWaypoint = d

func CalculateVario(delta):
	var TempTE = (Mass * altitudeM * 9.81) + (0.5 * Mass * (airspeedKMH/3.6)**2)
	var deltaTE = TE - TempTE
	TE = TempTE
	TETable.insert(0, deltaTE)
	TEVario = deltaTE/delta
	
	if TETable.size() > 165:
		TETable.remove_at(165)
	
	for i in TETable:
		TETableSum += i
	TETableSum = TETableSum / TETable.size()
	TEVario = -TETableSum / (Mass * 9.81)

func UpdateCalculations(delta):
	#in flight calculations
	CalculateVario(delta)
	CalculateDistance(delta)

func decodeCondorPacket(packet: PackedByteArray):
	var packetDecoded = packet.get_string_from_utf8()
	var lines := packetDecoded.split("\n", false)
	for line in lines:
		if line.contains("airspeed"):
			airspeedKMH = 3.6 * line.split("=", false, 2)[1].to_float()
			airspeedKTS = 3.6 * line.split("=", false, 2)[1].to_float() * 0.539956803
		if line.contains("altitude"):
			altitudeM = line.split("=", false, 2)[1].to_float()
		if line.contains("evario"):
			TEVario = line.split("=", false, 2)[1].to_float()
		if line.contains("gforce="):
			g_force = line.split("=", false, 2)[1].to_float()
		if line.contains("yaw="):
			heading = rad_to_deg(line.split("=", false, 2)[1].to_float())
		if line.contains("pitch="):
			pitch = rad_to_deg(line.split("=", false, 2)[1].to_float())
		if line.contains("bank="):
			roll = -rad_to_deg(line.split("=", false, 2)[1].to_float())
		if line.contains("bank="):
			roll = -rad_to_deg(line.split("=", false, 2)[1].to_float())
	
func decodeXplanePacket(packet: PackedByteArray):
	#get header and verify DATA line
	var header = packet.slice(0,4).get_string_from_utf8()
	
	#packet sizes
	var header_size = 5
	var line_size = 36
	
	for i in packet.size()/line_size:
		var base = header_size + i * line_size

		#get all parts of the packet and decode them
		var index = packet.slice(base, base + 4).decode_u32(0)
		var val0 = packet.slice(base + 4,  base + 8).decode_float(0)
		var val1 = packet.slice(base + 8,  base + 12).decode_float(0)
		var val2 = packet.slice(base + 12, base + 16).decode_float(0)
		var val3 = packet.slice(base + 16, base + 20).decode_float(0)
		var val4 = packet.slice(base + 20, base + 24).decode_float(0)
		var val5 = packet.slice(base + 24, base + 28).decode_float(0)
		var val6 = packet.slice(base + 28, base + 32).decode_float(0)
		var val7 = packet.slice(base + 32, base + 36).decode_float(0)
		
		#print(header, " ", index, " ", val0, " ", val1, " ", val2, " ", val3, " ", val4, " ", val5, " ", val6, " ", val7)
		
		if index == 17:
			pitch = val0
			roll = val1
			heading = val2
		if index == 4:
			g_force = val4
		if index == 3:
			airspeedKTS = val0
			airspeedKMH = val0 * 1.85200
		if index == 20:
			longtitude = val0
			latitude = val1
			altitudeM = val2 * 0.3048

func _ready():
	var os_name = OS.get_name()
	if os_name == "Android" or os_name == "iOS":
		MobileMode = true
	
	var err = XplaneUDP.bind(49003, "127.0.0.1")
	if err != OK:
		push_error("Failed to bind udp port" )
	else:
		print("Listening for X-Plane on udp port 49003")
	
	var err2 = CondorUDP.bind(55278,"127.0.0.1")
	if err2 != OK:
		push_error("Failed to bind udp port")
	else:
		print("Listening for Condor on udp port 55278")
		
func _process(delta: float) -> void:
	DisplaySize = DisplayServer.window_get_size()
	DisplayCenter = DisplayServer.window_get_size()/2
	
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/main menu.tscn")
	
	while XplaneUDP.get_available_packet_count() > 0:
		var packet: PackedByteArray = XplaneUDP.get_packet()
		if packet:
			XPlaneUPDConnection = true
			decodeXplanePacket(packet)
		else:
			XPlaneUPDConnection = false
	while CondorUDP.get_available_packet_count() > 0:
		var packet: PackedByteArray = CondorUDP.get_packet()
		if packet:
			CondorUDPConnection = true
			decodeCondorPacket(packet)
		else:
			CondorUDPConnection = false
	
	if XPlaneUPDConnection or CondorUDPConnection:
		UPDConnection = true
	else:
		UPDConnection = false
	
	UpdateCalculations(delta)
