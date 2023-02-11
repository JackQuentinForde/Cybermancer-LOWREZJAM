extends KinematicBody2D

const GRAVITY_FORCE = 1500
const MAX_GRAVITY = 750
const RUN_SPEED = 120
const AIR_ACCEL = 6
const MAX_DIST = 450
const MAX_SHOOT_TIME = 1
const MAX_SHOTS = 5
const MAX_MOVE_TIME = 3
const LASER_TRAVEL_TIME = 1
const POINTS = 125

export(bool) var stationary

var spawnLocation = Vector2(0,0)
var firstSpawn = true
var firstDeath = true

var closestPlayerPos = Vector2(0, 0)

var velocity = Vector2(0, 0)
var opacity = 0
var faceLeft = false 
var running = false
var shooting = false
var killed = false
var distance = 0
var shootTime = 0
var numShots = 0
var moveTime = 0

func _ready():

	if (firstSpawn):
		spawnLocation = get_global_pos()
		firstSpawn = false
	else:
		velocity = Vector2(0, 0)
		opacity = 0
		faceLeft = false 
		running = false
		shooting = false
		killed = false
		shootTime = 0
		numShots = 0
		moveTime = 0
		
	randomize()
	numShots = floor(rand_range(0,MAX_SHOTS-1))
	if (!stationary):
		randomize()
		moveTime = rand_range(0,MAX_MOVE_TIME-1)
		
	get_node("Sprite").set_opacity(opacity)	
	
	set_fixed_process(true)
	
func _fixed_process(delta):

	if (opacity < 1):
		opacity += delta
		get_node("Sprite").set_opacity(opacity)

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
		
		if (numShots <= MAX_SHOTS):
		
			if (closestPlayerPos.x > pos.x):
				faceLeft = false
			elif (closestPlayerPos.x < pos.x):
				faceLeft = true
		
			if (!shooting and (opacity >= 1)):
				shoot()
			elif (shootTime < MAX_SHOOT_TIME):
				shootTime += delta
			else:
				shooting = false
				
		elif (!stationary and (moveTime < MAX_MOVE_TIME)):
			search()
			moveTime += delta
		else:
			if (!stationary):
				randomize()
				numShots = floor(rand_range(0,MAX_SHOTS-1))
				randomize()
				moveTime = rand_range(0,MAX_MOVE_TIME-1)
			else:
				numShots = 0
			velocity = Vector2(0,0)
			if (get_node("Sprite/AnimationPlayer").is_playing()):
				get_node("Sprite/AnimationPlayer").stop()
		
	var motion = velocity * delta
	motion = move(motion)
	checkCollisions(delta, motion)
	handleAnimations()
	
	if (killed):
		set_global_pos(spawnLocation)
		get_node("Sprite").set_frame(8)
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
					
func shoot():
	shooting = true
	shootTime = 0
	numShots += 1
	
	if (numShots < MAX_SHOTS):
		get_node("SamplePlayer").play("laser")
		var laser = preload("res://Assets/_Scenes/Laser.tscn").instance()
		laser.setEnemyLaser()
		laser.setMaxTravelTime(LASER_TRAVEL_TIME)
		laser.get_node("Sprite").set_modulate(get_node("Sprite").get_modulate())
		if (faceLeft):
			laser.faceLeft = true
			laser.set_pos((get_global_pos()) + Vector2(-14,8))
		else:
			laser.faceLeft = false
			laser.set_pos((get_global_pos()) + Vector2(22,8))
	
		get_node("../../").add_child(laser)
	
func search():		
	if (faceLeft):
		if (running):
			velocity.x = -RUN_SPEED
		else:
			if (velocity.x > -RUN_SPEED):
				velocity.x -= AIR_ACCEL
			else:
				velocity.x = -RUN_SPEED
	else:
		if (running):
			velocity.x = RUN_SPEED
		else:
			if (velocity.x < RUN_SPEED):
				velocity.x += AIR_ACCEL
			else:
				velocity.x = RUN_SPEED
	
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
			running = true
		else:
			running = false
			if (faceLeft):
				faceLeft = false
			else:
				faceLeft = true
			
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	
func handleAnimations():
	
	if (faceLeft and (get_node("Sprite").is_flipped_h())):
		get_node("Sprite").set_flip_h(false)
	elif (!faceLeft and (!get_node("Sprite").is_flipped_h())):
		get_node("Sprite").set_flip_h(true)
	
	if ((numShots <= MAX_SHOTS) and (get_node("Sprite").get_frame() != 8)):
		get_node("Sprite").set_frame(8)
		
	elif (!stationary and (numShots > MAX_SHOTS) and (!get_node("Sprite/AnimationPlayer").is_playing())):
		get_node("Sprite/AnimationPlayer").play("run")
				
func destroy():
	get_node("SamplePlayer").play("death")
	ghost()
	if (get_node("Sprite/AnimationPlayer").is_playing()):
		get_node("Sprite/AnimationPlayer").stop()
	killed = true
	
func ghost():
	var ghost = preload("res://Assets/_Scenes/Ghost.tscn").instance()
	ghost.set_pos(get_global_pos())
	ghost.set_flip_h(get_node("Sprite").is_flipped_h())
	ghost.set_frame(get_node("Sprite").get_frame())
	get_node("../").add_child(ghost)
	
	