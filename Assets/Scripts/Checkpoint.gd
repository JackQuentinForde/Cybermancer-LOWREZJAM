extends Area2D

const P1_COLOUR = Color(255,0,255,255)
const P2_COLOUR = Color(255,255,0,255)

func _ready():
	connect("body_enter",self,"collison")
	
func collison(body):
	if (body.get_parent().get_name() == "Players"):
		var name = body.get_name()
		for i in range(get_parent().get_child_count()):
			var child = get_parent().get_child(i)
			if (child.get_name() != get_name()):
				if (name == "Player1"):
					if (child.get_node("Sprite").get_modulate() != P2_COLOUR):
						child.get_node("Sprite").set_modulate(Color(255,255,255,255))
				else:
					if (child.get_node("Sprite").get_modulate() != P1_COLOUR):
						child.get_node("Sprite").set_modulate(Color(255,255,255,255))
		if (name == "Player1"):
			if (get_node("Sprite").get_modulate() != P1_COLOUR):
				get_node("Sprite").set_modulate(P1_COLOUR)
				get_node("SamplePlayer").play("checkpoint")
		else:
			if (get_node("Sprite").get_modulate() != P2_COLOUR):
				get_node("Sprite").set_modulate(P2_COLOUR)
				get_node("SamplePlayer").play("checkpoint")
		body.setCheckPoint(get_global_pos())
