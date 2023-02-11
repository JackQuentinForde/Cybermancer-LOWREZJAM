extends Area2D

const POINTS = 1000

func _ready():
	get_node("Sprite/AnimationPlayer").play("flash")
	connect("body_enter",self,"collison")
	
func collison(body):
	if (body.get_parent().get_name() == "Players"):
		if (Global.deaths <= 5):
			Global.addScore(POINTS * 4)
		else:
			Global.addScore(POINTS)
		body.finish()
	elif (body.get_parent().get_name() == "Enemies"):
		if (!body.killed):
			body.destroy()