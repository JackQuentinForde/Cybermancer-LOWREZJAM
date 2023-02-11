extends Area2D

func _ready():
	connect("body_enter",self,"collison")
	
func collison(body):
	if (body.get_parent().get_name() == "Players"):
		body.respawn()
	elif (body.get_parent().get_name() == "Enemies"):
		if (!body.killed):
			body.destroy()