
extends Node2D

var API_KEY = "ENTER API KEY HERE"
var loadingscreen = true
var Zoom : float = 2
var X = 0
var Y = 0
const MapdataDir = "user://MAPDATA/"
var AirportData = []
var FrequenciesData = []
var RunwayscData = []
var NavaidsData = []
var AirportDat = {
	"Airports": {
		"URL": "https://api.core.openaip.net/api/airports?apiKey=" + API_KEY,
		"Location": "user://MAPDATA/Airports",
		"Folder": "user://MAPDATA/",
	},
}
var AirportMultiMesh = MultiMesh.new()
var AirportMultiMeshInstance = MultiMeshInstance2D.new()
var mesh = QuadMesh.new()


func inputHandler():
	if Input.is_action_just_pressed("ui_up"):
		Y = Y + 25 / Zoom
	if Input.is_action_just_pressed("ui_down"):
		Y = Y - 25 / Zoom
	if Input.is_action_just_pressed("ui_left"):
		X = X + 25 / Zoom
	if Input.is_action_just_pressed("ui_right"):
		X = X - 25 / Zoom
	if Input.is_action_just_pressed("ui_zoom_in"):
		Zoom = Zoom + Zoom
		print(Zoom)
	if Input.is_action_just_pressed("ui_zoom_out"):
		Zoom = Zoom - Zoom / 2
		print(Zoom)
	

		
func CoordsToPixel(coords : Vector2 ): 
	coords.x = coords.x + X
	coords.y = -coords.y + Y
	return Vector2(coords.x, coords.y)

func InitMapDat(): # check if all files are in place and look for .xcm files and draw them
	var HTTPRequestData = HTTPRequest.new()
	var json = JSON.new()
	add_child(HTTPRequestData)
	
	# air data
	var FolderMAPDATA = DirAccess.open(MapdataDir)
	if not FolderMAPDATA:
		push_error("ERROR No mapdata folder, attempting creation")
		DirAccess.make_dir_absolute(MapdataDir)

	
	for n in AirportDat:
		if not FileAccess.open(AirportDat[n]["Location"] + ".csv", FileAccess.READ):
			print("airport data not found, Attempting redownload, INDEX: ", n)
			
			# initiate download load
			HTTPRequestData.download_file = AirportDat[n]["Location"] + ".csv"
			var error = HTTPRequestData.request(AirportDat[n]["URL"])
			await HTTPRequestData.request_completed
			var file = FileAccess.open(AirportDat[n]["Location"] + ".csv", FileAccess.READ)
			var FileDat = file.get_as_text()
			var err = json.parse(FileDat)
			var currentPage = json.data["page"]
			var maxPage = json.data["totalPages"]
			
			for o in range(1, maxPage + 1):
				HTTPRequestData.download_file = AirportDat[n]["Location"] + str(o) + ".csv"
				var errorHTTP = HTTPRequestData.request(AirportDat[n]["URL"]+"&page="+str(o))
				await HTTPRequestData.request_completed
				
				file = FileAccess.open(AirportDat[n]["Location"] + ".csv", FileAccess.READ)
				print(file)
				FileDat = file.get_as_text()
				error = json.parse(FileDat)
				currentPage = json.data["page"]
				maxPage = json.data["totalPages"]
				for i in json.data["items"].size():
					AirportData.append(Vector2(json.data["items"][i]["geometry"]["coordinates"][0], json.data["items"][i]["geometry"]["coordinates"][1]))
				file.close()
				print("Downloading OpenAIP data: ", o)
			
			if error != OK:
				push_error("An error occurred in the HTTP request.", error)
			else:
				print("Download Completed! ", HTTPRequestData.download_file)
			print("Exited error code: ", error)
		else:
			print(AirportDat[n]["Location"] + ".csv"," data found!")
			# initiate normal load
			
			var dir := DirAccess.open(AirportDat[n]["Folder"])
			if dir == null:
				print("Cannot open folder", AirportDat[n]["Folder"])
			dir.list_dir_begin()
			var file_name = dir.get_next()
			var csv_files = []
			while file_name != "":
				if file_name.begins_with("Airports") and file_name.ends_with(".csv"):
					csv_files.append(file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
			
			for i in range(1, csv_files.size()):
				var file = FileAccess.open(AirportDat[n]["Location"] + str(i) + ".csv", FileAccess.READ)
				var FileDat = file.get_as_text()
				var error = json.parse(FileDat)
				for a in json.data["items"].size():
					AirportData.append(Vector2(json.data["items"][a]["geometry"]["coordinates"][0], json.data["items"][a]["geometry"]["coordinates"][1]))
				file.close()
				print("file ", i, " Done")


	#multimesh setup
	
	
	mesh.size = Vector2(1,1)
	AirportMultiMesh.mesh = mesh
	AirportMultiMesh.transform_format = MultiMesh.TRANSFORM_2D
	AirportMultiMesh.instance_count = AirportData.size()
	
	for i in range(AirportData.size()):
		var transform = CoordsToPixel(AirportData[i])
		AirportMultiMesh.set_instance_transform_2d(i, Transform2D(0, transform))
		AirportMultiMesh.set_instance_color(i, Color(0,0,1))
	
	AirportMultiMeshInstance.multimesh = AirportMultiMesh
	AirportMultiMeshInstance.z_index = -1
	add_child(AirportMultiMeshInstance)
	AirportMultiMeshInstance.position = Vector2(Global.DisplayCenter.x, Global.DisplayCenter.y) - Vector2(Zoom, Zoom)
	
func _draw():
	if loadingscreen:
		draw_char(Global.default_font, Global.DisplayCenter, "Test")
	draw_circle(Global.DisplayCenter, 1, Global.white_color)
	
	#heading line
	var edgePos = Vector2(Global.DisplayCenter.x+cos(deg_to_rad(Global.heading-90))*10*Global.DisplaySize.y,Global.DisplayCenter.x+sin(deg_to_rad(Global.heading-90))*10*Global.DisplaySize.y)
	draw_line(Global.DisplayCenter, edgePos, Global.white_color)


func _init():
	var grid = GridContainer.new()
	var zoomIn = Button.new()
	var zoomOut = Button.new()
	
	zoomIn.text = "+"
	zoomOut.text = "-"
	grid.columns = 1
	grid.position.x = Global.DisplaySize.x - 100
	loadingscreen = true
	InitMapDat()

func _process(_delta):
	#print(X," ", Y)
	inputHandler()
	
	if Global.UPDConnection:
		X = Global.latitude
		Y = Global.longtitude
	
	if Zoom > 0:
		mesh.size = Vector2((10/Zoom),(10/Zoom))
	for i in range(AirportData.size()):
		var transform = CoordsToPixel(AirportData[i])
		AirportMultiMesh.set_instance_transform_2d(i, Transform2D(0, transform))
	AirportMultiMeshInstance.scale = Vector2(Zoom, Zoom)
	AirportMultiMeshInstance.position = Vector2(Global.DisplayCenter.x, Global.DisplayCenter.y)
	queue_redraw()
