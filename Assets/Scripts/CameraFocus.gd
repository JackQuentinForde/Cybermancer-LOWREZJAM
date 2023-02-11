extends Node2D

const CAM_OFFSSET = Vector2(400,-250)
const MAX_DIST = 750

var focusPoint = Vector2(0,0)

func _ready():
	set_process(true)
	
func _process(delta):

	if (Global.singlePlayer):
		focusPoint = get_node("../Player1").get_global_pos()
	else:
		var p1Pos = get_node("../Player1").get_global_pos()
		var p2Pos = get_node("../Player2").get_global_pos()
		focusPoint = (p2Pos - p1Pos)/2 + p1Pos
		var dist = p1Pos.distance_to(p2Pos)
		if (dist >= MAX_DIST):
			get_node("../Player2").setCheckPoint(get_node("../Player1").checkPoint)
			get_node("../Player2").ghost()
			get_node("../Player2").set_global_pos(get_node("../Player1").get_global_pos())
	
	focusPoint -= CAM_OFFSSET
	set_global_pos(focusPoint)