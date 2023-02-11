extends Area2D

var speed = 800
var maxTravelTime = 1
var travelTime = 0
var faceUp = false
var faceDown = false
var faceLeft = false
var enemyLaser = false

func _ready():
	connect("body_enter",self,"collison")
	get_node("Sprite").hide()
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (travelTime < maxTravelTime):
		if (faceUp):
			if (get_rot() != 90):
				set_rot(1.5708)
			translate(Vector2(0, delta*-speed))
		elif (faceDown):
			if (get_rot() != 90):
				set_rot(1.5708)
			translate(Vector2(0, delta*speed))
		else:
			if (get_rot() != 0):
				set_rot(0)
			if (faceLeft):
				translate(Vector2(delta*-speed, 0))
			else:
				translate(Vector2(delta*speed, 0))
		travelTime += delta
	else:
		destroy()
		
	if (get_node("Sprite").is_hidden()):
		get_node("Sprite").show()
		
func collison(body):
	if (enemyLaser):
		if (body.get_parent().get_name() != "Enemies"):
			if ((body.get_parent().get_name() == "Players") and !body.invincible):
				body.respawn()
			destroy()
	else:
		if (body.get_parent().get_name() != "Players"):
			if (body.get_parent().get_name() == "Enemies"):
				if (body.has_method("hit")):
					body.hit()
				else:
					body.destroy()
			destroy()
		
func setEnemyLaser():
	enemyLaser = true
	speed = 500
	
func setMaxTravelTime(var in_maxTravelTime):
	maxTravelTime = in_maxTravelTime
	
func destroy():
	set_process(false)
	queue_free()	