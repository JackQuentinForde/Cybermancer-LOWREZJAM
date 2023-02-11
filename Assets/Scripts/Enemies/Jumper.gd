extends KinematicBody2D

const COLOUR = Color(255, 0, 0, 255)
const GRAVITY_FORCE = 1500
const MAX_GRAVITY = 750
const JUMP_VELOCITY = 504
const FALL_VELOCITY = 120
const ACCEL = 24
const MAX_GROUND_TIME = 0.5
const MAX_JUMP_TIME = 0.15
const MAX_FLASH_TIME = 0.1
const MAX_DIST = 450
const LASER_TRAVEL_TIME = 1
const POINTS = 250

var spawnLocation = Vector2(0,0)
var firstSpawn = true
var firstDeath = true

var closestPlayerPos = Vector2(0, 0)

var velocity = Vector2(0, 0)
var opacity = 0
var faceLeft = false 
var onGround = false
var shooting = false
var killed = false
var health = 1
var distance = 0
var groundTime = 0
var jumpTime = 0
var flashTime = MAX_FLASH_TIME

func _ready():

	if (firstSpawn):
		spawnLocation = get_global_pos()
		firstSpawn = false
	else:
		velocity = Vector2(0, 0)
		opacity = 0
		health = 1
		faceLeft = false 
		onGround = false
		shooting = false
		killed = false
		jumpTime = 0
		flashTime = MAX_FLASH_TIME
	
	randomize()
	groundTime = (rand_range(0,MAX_GROUND_TIME))
	
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
		
	applyGravity(delta)
	
	var pos = get_global_pos()
	
	closestPlayerPos = get_node("../../Players/Player1").get_global_pos()
	distance = pos.distance_to(closestPlayerPos)
	
	if (!Global.singlePlayer):
		var p2Pos = get_node("../../Players/Player2").get_global_pos()
		if (pos.distance_to(p2Pos) < distance):
			closestPlayerPos = p2Pos
			distance = pos.distance_to(closestPlayerPos)
		
	if (distance <= MAX_DIST):
	
		if (!onGround and !shooting and (closestPlayerPos.y > pos.y) and ((closestPlayerPos.x <= pos.x + 4) and (closestPlayerPos.x >= pos.x - 4))):
			shoot()
		
		if (groundTime >= MAX_GROUND_TIME):
			
			if (closestPlayerPos.x > pos.x):
				faceLeft = false
			elif (closestPlayerPos.x < pos.x):
				faceLeft = true
				
			search(delta)
			
		elif (onGround and (opacity >= 1)):
			velocity.x = 0
			shooting = false
			groundTime += delta
			
	var motion = velocity * delta
	motion = move(motion)
	checkCollisions(delta, motion)
	handleAnimations()
	
	if (killed):
		set_global_pos(spawnLocation)
		get_node("Sprite").set_frame(0)
		if (firstDeath):
			Global.addScore(POINTS)
			firstDeath = false
		Global.addKill()
		get_parent().remove_child(get_node(get_path()))
	
func applyGravity(var delta):
	if (velocity.y < MAX_GRAVITY):
		velocity.y += delta * GRAVITY_FORCE
		if (velocity.y > MAX_GRAVITY):
			velocity.y = MAX_GRAVITY
			
func search(var delta):
	if (faceLeft and (velocity.x > -JUMP_VELOCITY)):
		velocity.x -= ACCEL
	elif (!faceLeft and (velocity.x < JUMP_VELOCITY)):
		velocity.x += ACCEL

	if (jumpTime < MAX_JUMP_TIME):
		velocity.y = -JUMP_VELOCITY
		jumpTime += delta
	else:
		jumpTime = 0
		groundTime = 0
		if (velocity.y < 0):
			velocity.y += FALL_VELOCITY
			
func shoot():
	shooting = true
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
		
		var n  = get_collision_normal()
		if (rad2deg(acos(n.dot(Vector2(0,-1)))) == 0):
			onGround = true
		else:
			onGround = false
			
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	else:
		onGround = false
		
func handleAnimations():
	if (onGround and (get_node("Sprite").get_frame() != 0)):
		get_node("Sprite").set_frame(0)
	elif (!onGround and (get_node("Sprite").get_frame() != 1)):
		get_node("Sprite").set_frame(1)
		
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
