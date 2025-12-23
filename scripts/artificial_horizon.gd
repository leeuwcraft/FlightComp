@tool
extends Node2D

#variables and constants
var mag = Vector3(-1,-1,-1)
var accel = Vector3(-1,-1,-1)
var accelSmoothed := Vector3()
var magSmoothed := Vector3()

var roll = 0
var pitch = 0
var heading = 0
var headingRad = 0
var headingDeg = 0

@export var AirspeedNeedle : Curve
@export var AltimeterNeedle : Curve
@export var VarioNeedle : Curve

#zero p1 & p2
var p1 = Vector2(0,0)
var p2 = Vector2(0,0)

var centerInt = DisplayServer.window_get_size()/2
var center = Vector2(centerInt.x, centerInt.y)
var BracketTWidth = center.x / 6
var BracketHWidth = BracketTWidth/8

const HorizonLength = 5000
const smoothing = 0.1
const degSepLineCt = 19


func DrawingComponents():
	Ui.drawDial(self, Global.DisplayCenter, 50, Global.white_color, 10, 10)
	# TODO FIX SPAGETTI
	
	# ** F U N C  V A R I A B L E S **
	var G_force = round(accelSmoothed.length() / 9.81 * 100) / 100
	var G_Color = Color(1,1,1)
	var ErrorMsg = ""
	var ErrorMsgWidth = 400
	
	# ** A R T I F I C I A L  H O R I Z O N **
	var p1 = Vector2(0-HorizonLength,-pitch/PI*center.y*2).rotated(roll) + center # positions for the horizon and their formula
	var p2 = Vector2(0+HorizonLength,-pitch/PI*center.y*2).rotated(roll) + center # calculate in the draw function for ease of us	
	
	# get the heading and accel data and compensate for pitch
	var east = accelSmoothed.normalized().cross(magSmoothed).normalized()
	var north = east.cross(accelSmoothed.normalized()).normalized()
	if not Global.UDPConnection:
		headingRad = atan2(north.x, -east.x)
		headingDeg = rad_to_deg(headingRad)
	
	if headingDeg < 0:
		headingDeg += 360
	#draw function stack
	draw_polygon(SkyColor, PackedColorArray([Global.sky_color_bottom, Global.sky_color_bottom, Global.sky_color_top, Global.sky_color_top]))
	draw_polygon(GroundColor, PackedColorArray([Global.ground_color_top, Global.ground_color_top, Global.ground_color_bottom, Global.ground_color_bottom]))
	draw_line(p1,p2, Global.white_color, 3)
			#for each 10 degree line
	for n in degSepLineCt:
		draw_line(Vector2(0-BracketTWidth,(deg_to_rad(90-10*n)-pitch)/PI*center.y*2).rotated(roll) + center,
					Vector2(0+BracketTWidth,(deg_to_rad(90-10*n)-pitch)/PI*center.y*2).rotated(roll) + center, Global.white_color, 3)
		draw_line(Vector2(0-BracketTWidth/2,(deg_to_rad(95-10*n)-pitch)/PI*center.y*2).rotated(roll) + center,
					Vector2(0+BracketTWidth/2,(deg_to_rad(95-10*n)-pitch)/PI*center.y*2).rotated(roll) + center, Global.white_color, 3)
		if n != degSepLineCt/2: # check for 0 degrees
			draw_string(Global.default_font, Vector2(0-BracketTWidth,(deg_to_rad(90-10*n)-pitch)/PI*center.y*2+5-10).rotated(roll) + center, str(-n*10+90))
			draw_string(Global.default_font, Vector2(25+BracketTWidth,(deg_to_rad(90-10*n)-pitch)/PI*center.y*2+5-10).rotated(roll) + center, str(-n*10+90))
	# draw heading indicator
	draw_polygon(BracketLeft, PackedColorArray([Global.yellow, Global.yellow, Global.dark_yellow, Global.yellow]))
	draw_polygon(BracketRight, PackedColorArray([Global.yellow, Global.yellow, Global.dark_yellow, Global.yellow]))
	draw_polyline(BracketLeft, Global.white_color, 3)
	draw_polyline(BracketRight, Global.white_color, 3)

	#** S P E E D  &  A L T I T U D E **
	var radiusVar =  Global.DisplayCenter.x*0.6
	var incrementLines1 = 25+1 #increments in 10km/h
	var incrementLines2 = 100 
	var AirspeedTextInterval = 1 #to add interval between text
	var AltimeterTextInterval = 10
	
	var thousands = 0
	for i in Global.altitudeM/1000 - 1:
		thousands = thousands + 1000
	var needleAirspeedAngle = 180 - AirspeedNeedle.sample(Global.airspeedKMH) - 90
	var needleAltimeterAngle = AltimeterNeedle.sample(Global.altitudeM - thousands) + 90
	var needleVarioAngle = VarioNeedle.sample(Global.TEVario) + 90
	
	draw_circle(Vector2(0, Global.DisplayCenter.y), radiusVar, Global.background_transparent)
	draw_circle(Vector2(Global.DisplaySize.x, Global.DisplayCenter.y), radiusVar, Global.background_transparent)
	#SPEED INDICATOR
	for i in incrementLines1:
		var linelength = 100
		var pos1Offset =  40
		var pos2Offset = 30
		var pos3Offset = 15
		var pos4Offset = 120
		var pos5Offset = 35
		var angle = -AirspeedNeedle.sample(i*10) + 90
		var pos1 = Vector2(0 + cos(deg_to_rad(angle))*(radiusVar-pos1Offset), Global.DisplayCenter.y + sin(deg_to_rad(angle))*(radiusVar-pos1Offset))
		var pos2 = Vector2(0 + cos(deg_to_rad(angle))*(radiusVar-pos2Offset), Global.DisplayCenter.y + sin(deg_to_rad(angle))*(radiusVar-pos2Offset))
		var pos3 = Vector2(0 + cos(deg_to_rad(angle))*(radiusVar-pos3Offset), Global.DisplayCenter.y + sin(deg_to_rad(angle))*(radiusVar-pos3Offset))
		var pos4 = Vector2(0 + cos(deg_to_rad(needleAirspeedAngle))*(radiusVar-pos4Offset), Global.DisplayCenter.y + sin(deg_to_rad(needleAirspeedAngle))*(radiusVar-pos4Offset))
		var pos5 = Vector2(0 + cos(deg_to_rad(needleAirspeedAngle))*(radiusVar-pos5Offset), Global.DisplayCenter.y + sin(deg_to_rad(needleAirspeedAngle))*(radiusVar-pos5Offset))
		draw_line(pos1, pos2 , Global.white_color, 2) #increment line
		if i%AirspeedTextInterval == 0:
			draw_string(Global.default_font, Vector2(pos3.x-10,pos3.y+10), str(i*10), 0, -1) #text 
		if i == 0: #only draw once
			draw_line(pos5, pos4 , Global.white_color, 5) #needle
	
	#ALTIMETER
	for i in incrementLines2:
		var linelength = 100
		var pos1Offset =  40
		var pos2Offset = 30
		var pos3Offset = 15
		var pos4Offset = 120
		var pos5Offset = 35
		var pos6Offset = 0
		var pos7Offset = -20
		var angle = AltimeterNeedle.sample(i*10) + 90
		var pos1 = Vector2(Global.DisplaySize.x + cos(deg_to_rad(angle))*(radiusVar-pos1Offset), Global.DisplayCenter.y + sin(deg_to_rad(angle))*(radiusVar-pos1Offset))
		var pos2 = Vector2(Global.DisplaySize.x + cos(deg_to_rad(angle))*(radiusVar-pos2Offset), Global.DisplayCenter.y + sin(deg_to_rad(angle))*(radiusVar-pos2Offset))
		var pos3 = Vector2(Global.DisplaySize.x + cos(deg_to_rad(angle))*(radiusVar-pos3Offset), Global.DisplayCenter.y + sin(deg_to_rad(angle))*(radiusVar-pos3Offset))
		var pos4 = Vector2(Global.DisplaySize.x  + cos(deg_to_rad(needleAltimeterAngle))*(radiusVar-pos4Offset), Global.DisplayCenter.y + sin(deg_to_rad(needleAltimeterAngle))*(radiusVar-pos4Offset))
		var pos5 = Vector2(Global.DisplaySize.x  + cos(deg_to_rad(needleAltimeterAngle))*(radiusVar-pos5Offset), Global.DisplayCenter.y + sin(deg_to_rad(needleAltimeterAngle))*(radiusVar-pos5Offset))
		var pos6 = Vector2(Global.DisplaySize.x  + cos(deg_to_rad(needleVarioAngle))*(radiusVar-pos6Offset), Global.DisplayCenter.y + sin(deg_to_rad(needleVarioAngle))*(radiusVar-pos6Offset))
		var pos7 = Vector2(Global.DisplaySize.x  + cos(deg_to_rad(needleVarioAngle))*(radiusVar-pos7Offset), Global.DisplayCenter.y + sin(deg_to_rad(needleVarioAngle))*(radiusVar-pos7Offset))
		draw_line(pos1, pos2 , Global.white_color, 2) #increment line
		
		if i%AltimeterTextInterval == 0:
			draw_string(Global.default_font, Vector2(pos3.x-10,pos3.y+10), str(i*10), 0, -1) #text 
		if i == 0: #only draw once
			draw_line(pos5, pos4 , Global.white_color, 5) #needle
			draw_line(pos6, pos7 , Global.orange, 10) #needle
			draw_string(Global.default_font, Vector2(Global.DisplaySize.x-130, Global.DisplayCenter.y - 30), str(int(Global.altitudeM))+"M", 0, -1, 30)
			draw_string(Global.default_font, Vector2(Global.DisplaySize.x-150, Global.DisplayCenter.y + 30), str(floor(Global.TEVario * 100)/100)+"M/s", 0, -1, 30)
			
	#** H E A D I N G  I N D I C A T O R **
	var box = HeadingBox.new()
	draw_string(Global.default_font, Vector2(center.x-box.width/2, box.Ypos), str(round(headingDeg)), HORIZONTAL_ALIGNMENT_LEFT, box.width, box.size)
	draw_polyline(HeadingBoxOutline, Global.white_color, 3) #HeadingBox outline
	
	var HSI = HSICircle.new()
	var smallLineSpacing = 36
	#draw_arc(Vector2(center.x,center.y*0.5),center.y/3,deg_to_rad(-180),deg_to_rad(0), 100, Global.white_color, 3) # work in progress
	draw_circle(Vector2(HSI.PositionX,HSI.PositionY), HSI.Radius, Global.background_transparent, true) #HSI
	for n in smallLineSpacing:
		var angle = deg_to_rad(n*10-90-headingDeg)
		var radius = center.y/3.5
		var radius2 = Global.DisplaySize.y / 100
		var height = Global.DisplaySize.y/ 80
		var Pos1 = Vector2(center.x + cos(angle)*radius,center.y*1.5+ sin(angle)*radius)
		var Pos2 = Vector2(center.x + cos(angle)*(radius-height),center.y*1.5+ sin(angle)*(radius-height))
		var Pos3 = Vector2(center.x + cos(angle)*(radius+height),center.y*1.5+ sin(angle)*(radius+height))
		var Pos4 = Vector2(center.x + cos(angle)*(radius+height+10),center.y*1.5+ sin(angle)*(radius+height+10))
		# FIX \/ LINES WRONG
		draw_line(Pos1, Pos2, Global.white_color )
		if n % 9 == 0:
			var string = " "
			if n == 9:
				string = "E"
			if n == 18:
				string = "S"
			if n == 27:
				string = "W"
			if n == 0:
				string = "N"
			draw_line(Pos1,Pos3, Global.white_color)
			draw_string(Global.default_font, Pos4-Vector2(5,-5), string, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		
		if n == 0:
			draw_circle(Vector2(Global.DisplayCenter.x - radius/4,center.y*1.5), radius2, Global.white_color, false)
			draw_circle(Vector2(Global.DisplayCenter.x + radius/4,center.y*1.5), radius2, Global.white_color, false)
			draw_circle(Vector2(Global.DisplayCenter.x - radius/2,center.y*1.5), radius2, Global.white_color, false)
			draw_circle(Vector2(Global.DisplayCenter.x + radius/2,center.y*1.5), radius2, Global.white_color, false)
			#draw_texture(Global.Aircraft_texture, Vector2(Global.DisplayCenter.x, Global.DisplayCenter.y*1.5)) #Plane image
			
	#** D E B U G  T E X T **
	draw_string(Global.default_font, Vector2(20, 130), str(Global.longtitude)+" "+str(Global.latitude
	
	))
	
	#** G - I N D I C A T O R **
	if G_force < 0.9 or G_force > 1.1:
		G_Color = Color(1,0.6,0)
		ErrorMsg = "AHRS INNAC"
	draw_string(Global.default_font, Vector2(Global.DisplaySize.x-200, 100), "G: "+str(G_force), HORIZONTAL_ALIGNMENT_LEFT, -1, 50, G_Color)
	draw_string(Global.default_font, Vector2(Global.DisplaySize.x-ErrorMsgWidth, 200), ErrorMsg, HORIZONTAL_ALIGNMENT_CENTER, ErrorMsgWidth, 50, G_Color)
	

func updatePackedArrays():
	BracketLeft = PackedVector2Array([
		Vector2(center.x, center.y),
		Vector2(center.x - BracketTWidth, center.y + BracketTWidth),
		Vector2(center.x - BracketTWidth - BracketTWidth - BracketHWidth, center.y + BracketTWidth),
		Vector2(center.x, center.y)
	])
	BracketRight = PackedVector2Array([
		Vector2(center.x, center.y),
		Vector2(center.x + BracketTWidth, center.y + BracketTWidth),
		Vector2(center.x + BracketTWidth + BracketTWidth + BracketHWidth, center.y + BracketTWidth),
		Vector2(center.x, center.y)
	])
	GroundColor = PackedVector2Array([ # recalculate background positions each frame
		Vector2(0-HorizonLength,-pitch/PI*center.y*2).rotated(roll) + center,
		Vector2(0+HorizonLength,-pitch/PI*center.y*2).rotated(roll) + center,
		Vector2(0+HorizonLength,-pitch/PI*center.y*2 - HorizonLength).rotated(roll) + center,
		Vector2(0-HorizonLength,-pitch/PI*center.y*2 - HorizonLength).rotated(roll) + center,
	])
	SkyColor = PackedVector2Array([ # recalculate second background
		Vector2(0-HorizonLength,-pitch/PI*center.y*2).rotated(roll) + center,
		Vector2(0+HorizonLength,-pitch/PI*center.y*2).rotated(roll) + center,
		Vector2(0+HorizonLength,-pitch/PI*center.y*2 + HorizonLength).rotated(roll) + center,
		Vector2(0-HorizonLength,-pitch/PI*center.y*2 + HorizonLength).rotated(roll) + center,
	])
	var box = HeadingBox.new()
	HeadingBoxOutline = PackedVector2Array([
		Vector2(box.Xpos-box.width/2, box.Ypos+box.spacing),
		Vector2(box.Xpos+box.width/2, box.Ypos+box.spacing),
		Vector2(box.Xpos+box.width/2, box.Ypos-box.size+box.spacing),
		Vector2(box.Xpos-box.width/2, box.Ypos-box.size+box.spacing),
		Vector2(box.Xpos-box.width/2, box.Ypos+box.spacing),
	])

#colors in autoload

#Settings heading box layout

class HeadingBox:
	var size = 50
	var width = 90
	var Ypos = Global.DisplaySize.y * 0.075
	var Xpos = Global.DisplaySize.x / 2
	var spacing = 5


class HSICircle:
	var PositionX = Global.DisplayCenter.x
	var PositionY = Global.DisplayCenter.y*1.5
	var Radius = Global.DisplayCenter.y/3.5

#make more settings \/

# define packed vector arrays for drawing
var BracketLeft : PackedVector2Array
var BracketRight : PackedVector2Array
var GroundColor : PackedVector2Array
var SkyColor : PackedVector2Array
var box = HeadingBox.new()
var HeadingBoxOutline : PackedVector2Array

func _process(delta):
	centerInt = DisplayServer.window_get_size()/2
	center = Vector2(centerInt.x, centerInt.y)
	mag = Input.get_magnetometer()
	accel = Input.get_accelerometer() # write input
	if Global.UDPConnection == true:
		pitch = deg_to_rad(Global.pitch)
		roll = deg_to_rad(360-Global.roll+180)
		headingDeg = Global.heading
		headingRad = Global.heading / 360 * PI
		if Global.g_force:
			accel = Vector3(0,Global.g_force*9.81,0)
			accelSmoothed = accelSmoothed.lerp(accel, smoothing)
		else:
			accel = Vector3(0,9.81,0)
			accelSmoothed = accelSmoothed.lerp(accel, smoothing)
	else:
		magSmoothed = magSmoothed.lerp(mag, smoothing)
		accelSmoothed = accelSmoothed.lerp(accel, smoothing) #smooth written input
		roll = atan2(accelSmoothed.x, accelSmoothed.y) # set variables to calculated angles using input
		pitch = atan2(accelSmoothed.z, sqrt(accelSmoothed.x*accelSmoothed.x + accelSmoothed.y*accelSmoothed.y))
	

	updatePackedArrays()
	queue_redraw()
	
func _draw():
	DrawingComponents()
