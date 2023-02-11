extends Area2D

func _ready():
	connect("body_enter",self,"collison")
	
func collison(body):
	if (body.get_parent().get_name() == "Players"):
		if (!body.invincible):
			body.respawn()
		destroy()
		
func destroy():
	ghost()
	queue_free()
	
func ghost():
	var ghost = preload("res://Assets/_Scenes/Ghost.tscn").instance()
	ghost.set_texture(get_node("Sprite").get_texture())
	ghost.set_hframes(get_node("Sprite").get_hframes())
	ghost.set_vframes(get_node("Sprite").get_vframes())
	ghost.set_pos(get_global_pos())
	ghost.set_frame(get_node("Sprite").get_frame())
	get_node("../").add_child(ghost)