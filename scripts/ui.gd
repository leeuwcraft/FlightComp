extends Node


func drawDial(INSself, pos: Vector2, size: int, color: Color, range: int, tickLength : int):
	INSself.draw_circle(pos, size, Global.background_transparent)
	for i in range(range):
		var pos1 = Vector2(pos.x + cos(i)*tickLength, pos.y + sin(i)*tickLength)
		var pos2 = Vector2(pos.x + cos(i)*tickLength, pos.y + sin(i)*tickLength)
		INSself.draw_line(pos1, pos2, color)
