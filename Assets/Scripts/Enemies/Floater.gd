extends KinematicBody2D

const COLOUR = Color(255, 0, 0, 255)
const MAX_VELOCITY = 120
const ACCEL = 6
const MAX_DIST = 450
const MAX_LASER_DIST = 200
const MAX_SHOOT_INTERVAL = 1
const MAX_FLASH_TIME = 0.1
const LASER_TRAVEL_TIME = 1.5
const POINTS = 500

export(bool) var leftFirst

var spawnLocation = Vector2(0,0)
var firstSpawn = true
var firstDeath = true

var closestPlayerPos = Vector2(0, 0)

var velocity = Vector2(0, 0)
var opacity = 0
var distanceReached = false
var faceLeft = false
var killed = false
var health = 2
var shootTime = 0
var distance = 0
var flashTime = MAX_FLASH_TIME

func _ready():
	
	if (firstSpawn):
		spawnLocation = get_global_pos()
		firstSpawn = false
	else:
		velocity = Vector2(0, 0)
		opacity = 0
		health = 2
		distanceReached = false
		killed = false
		flashTime = MAX_FLASH_TIME
		
	if (leftFirst):
		faceLeft = true
	else:
		faceLeft = false
	
	randomize()
	shootTime = rand_range(0,MAX_SHOOT_INTERVAL)
	
	get_node("Sprite").set_modulate(Color(255, 0, 0, opacity))
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	if (opacity < 1):
		opacity += delta
		get_node("Sprite").set_modulate(Color(255, 0, 0, opacity))

	if (flashTime < MAX_FLASH_TIME):
		flashTime += delta
	elif ((opacity >= 1) and (get_node("Sprite").get_modulate() != COLOUR)):
		get_node("Sprite").set_modulate(COLOUR)
		
	var pos = get_global_pos()
	
	closestPlayerPos = get_node("../../Players/Player1").get_global_pos()
	distance = pos.distance_to(closestPlayerPos)
	
	if (!Global.singlePlayer):
		var p2Pos = get_node("../../Players/Player2").get_global_pos()
		if (pos.distance_to(p2Pos) < distance):
			closestPlayerPos = p2Pos
			distance = pos.distance_to(closestPlayerPos)
	
	if (opacity >= 1):
		if (!get_node("Sprite/AnimationPlayer").is_playing()):
			get_node("Sprite/AnimationPlayer").play("fly")
		fly(delta)
		if (shootTime >= MAX_SHOOT_INTERVAL):
			if (distance < MAX_DIST):
				shoot()
		else:
			shootTime += delta
		
	var motion = velocity * delta
	motion = move(motion)
	checkCollisions(delta, motion)
	
	if (killed):
		set_global_pos(spawnLocation)
		get_node("Sprite").set_frame(0)
		if (firstDeath):
			Global.addScore(POINTS)
			firstDeath = false
		Global.addKill()
		get_parent().remove_child(get_node(get_path()))
	
func fly(var delta):
	
	var pos = get_global_pos()
	
	if (faceLeft):
		
		if (velocity.x > -MAX_VELOCITY):
			velocity.x -= ACCEL
		else:
			velocity.x = -MAX_VELOCITY		
			
	else:
	
		if (velocity.x < MAX_VELOCITY):
			velocity.x += ACCEL
		else:
			velocity.x = MAX_VELOCITY
	
	if (pos.distance_to(spawnLocation) >= MAX_LASER_DIST):
		if (!distanceReached):
			if (faceLeft):
				faceLeft = false
			else:
				faceLeft = true
			distanceReached = true
	else:
		distanceReached = false
		
func shoot():
	shootTime = 0
	get_node("SamplePlayer").play("laser")
	var laser = preload("res://Assets/_Scenes/Laser.tscn").instance()
	laser.setEnemyLaser()
	laser.setMaxTravelTime(LASER_TRAVEL_TIME)
	laser.faceDown = true
	laser.set_pos((get_global_pos()) + Vector2(6,4))
	laser.get_node("Sprite").set_modulate(COLOUR)
	get_node("../../").add_child(laser)
		
func checkCollisions(var delta, var motion):

	if (is_colliding()):
		var body = get_collider()
		if(body.get_parent().get_name() == "Players"):
			if ((opacity >= 1) and (!body.invincible)):
				body.respawn()
			else:
				destroy()
		else:
			if (faceLeft):
				faceLeft = false
			else:
				faceLeft = true
		
		var n  = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
		
func hit():
	if ((health > 0) and (opacity >= 1)):
		health -= 1
		flashTime = 0
		get_node("SamplePlayer").play("hit")
		get_node("Sprite").set_modulate(Color(255,255,255,255))
	else:
		destroy()
		
func destroy():
	get_node("SamplePlayer").play("death")
	ghost()
	killed = true
	
func ghost():
	var ghost = preload("res://Assets/_Scenes/Ghost.tscn").instance()
	ghost.set_texture(get_node("Sprite").get_texture())
	ghost.set_hframes(get_node("Sprite").get_hframes())
	ghost.set_vframes(get_node("Sprite").get_vframes())
	ghost.set_pos(get_global_pos())
	ghost.set_frame(get_node("Sprite").get_frame())
	get_node("../").add_child(ghost)
		
	