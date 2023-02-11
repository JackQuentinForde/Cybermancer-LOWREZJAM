extends Area2D

const MAX_DIST = 500
const SPEED = 500

var falling = false

func _ready():
	connect("body_enter",self,"collison")
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	if (!falling):
		var pos = get_global_pos()
		for i in range (get_node("../../Players").get_child_count()):
			if (get_node("../../Players").get_child(i).get_name().substr(0,6) == "Player"):
				var playerPos = get_node("../../Players").get_child(i).get_global_pos()
				if (pos.distance_to(playerPos) <= MAX_DIST):
					if ((playerPos.y >= pos.y) and ((playerPos.x <= pos.x + 4) and (playerPos.x >= pos.x - 4))):
						falling = true
						get_node("SamplePlayer").play("bomb")
	else:
		translate(Vector2(0, delta*SPEED))
	
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