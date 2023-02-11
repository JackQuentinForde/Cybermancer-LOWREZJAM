extends KinematicBody2D

const GRAVITY_FORCE = 1500
const MAX_GRAVITY = 750
const RUN_SPEED = 240
const WARP_SPEED = 960
const AIR_ACCEL = 12
const JUMP_VELOCITY = 480
const FALL_VELOCITY = 120
const JUMP_MAX_TIME = 0.15
const JUMP_GRACE_PERIOD = 0.05
const SHOOT_PERIOD = 1
const FIRE_INTERVAL = 0.2
const FLASH_PERIOD = 0.05
const DEATH_GRACE_PERIOD = 3
const LASER_TRAVEL_TIME = 0.7

var velocity = Vector2(0, 0)
var fallTime = 0
var jumpTime = 0
var shootTime = 0
var fireTime = FIRE_INTERVAL
var flashTime = 0
var aliveTime = 0
var animPos = 0.0

var lookingUp = false
var shooting = false
var movingLeft = false
var movingRight = false
var warping = false
var jumping = false
var running = false
var prevJump = false
var prevWarp = false
var invincible = false
var animationChange = false

var Colour = Color(0,0,0,255)

var checkPoint = Vector2(0,0)
var player1 = false

var up
var shoot
var right
var left
var warp
var jump

func _ready():
	if (get_name() == "Player1"):
		Colour = Color(255, 255, 0, 255)
	elif (get_name() == "Player2"):
		Colour = Color(0, 255, 0, 255)
	get_node("Sprite").set_modulate(Color(255,255,255,255))
	checkPoint = get_global_pos()
	set_fixed_process(true)
	
	if ((!Global.singlePlayer) and (get_name() == "Player1")):
		player1 = true
		var p2 = preload("res://Assets/_Scenes/Player.tscn").instance()
		p2.set_name("Player2")
		p2.set_global_pos(Vector2(get_global_pos().x - 48, get_global_pos().y))
		get_parent().call_deferred("add_child", p2)
	
func _fixed_process(delta):

	if (Global.singlePlayer):
		up = Input.is_action_pressed("player1_up")
		shoot = Input.is_action_pressed("singlePlayer_shoot")
		left = Input.is_action_pressed("player1_left")
		right = Input.is_action_pressed("player1_right")
		warp = Input.is_action_pressed("singlePlayer_warp")
		jump = Input.is_action_pressed("singlePlayer_jump")
	elif (player1):
		up = Input.is_action_pressed("player1_up")
		shoot = Input.is_action_pressed("player1_shoot")
		left = Input.is_action_pressed("player1_left")
		right = Input.is_action_pressed("player1_right")
		warp = Input.is_action_pressed("player1_warp")
		jump = Input.is_action_pressed("player1_jump")
	else:
		up = Input.is_action_pressed("player2_up")
		shoot = Input.is_action_pressed("player2_shoot")
		left = Input.is_action_pressed("player2_left")
		right = Input.is_action_pressed("player2_right")
		warp = Input.is_action_pressed("player2_warp")
		jump = Input.is_action_pressed("player2_jump")
		
	if (aliveTime < DEATH_GRACE_PERIOD):
		aliveTime += delta
		invincible = true
		if (flashTime >= FLASH_PERIOD):
			flashTime = 0
			if (get_node("Sprite").get_modulate() != Colour):
				get_node("Sprite").set_modulate(Colour)
			else:
				get_node("Sprite").set_modulate(Color(255,255,255,255))
		else:
			flashTime += delta
	else:
		get_node("Sprite").set_modulate(Colour)
		invincible = false
		
	applyGravity(delta)
		
	#Input Processing
	if (up):
		if (shooting and !lookingUp and (velocity.x != 0)):
			animationChange = true
		lookingUp = true
	else:
		if (shooting and lookingUp and (velocity.x != 0)):
			animationChange = true
		lookingUp = false
		
	if (shoot):
		shoot(delta)
	else:
		if (shootTime < SHOOT_PERIOD):
			shootTime += delta
			if (shootTime >= SHOOT_PERIOD):
				animationChange = true
		else:
			shooting = false
		fireTime = FIRE_INTERVAL
		
	if (warp and !prevWarp):
		if (!warping):
			warp()
	elif (warping):
		warping = false
	
	if (left and !movingRight):
		if (warping):
			moveLeft(WARP_SPEED)
		else:
			moveLeft(RUN_SPEED)
		
	elif (right and !movingLeft):
		if (warping):
			moveRight(WARP_SPEED)
		else:
			moveRight(RUN_SPEED)
	
	else:
		movingLeft = false
		movingRight = false
		if (running):
			velocity.x = 0
		elif (velocity.x > 0):
			velocity.x -= AIR_ACCEL
		elif (velocity.x < 0):
			 velocity.x += AIR_ACCEL
			
	var motion = velocity * delta
	motion = move(motion)
	handleAnimations()
	checkCollisions(delta, motion)
	jumpLogic(delta, jump)
	prevJump = jump
	if (prevWarp and !running):
		pass
	else:
		prevWarp = warp
	
func applyGravity(var delta):
	if (!jumping and velocity.y < MAX_GRAVITY):
		velocity.y += delta * GRAVITY_FORCE
		if (velocity.y > MAX_GRAVITY):
			velocity.y = MAX_GRAVITY
			
func shoot(var delta):
	if (!shooting and (velocity.x != 0)):
		animationChange = true
	shooting = true
	shootTime = 0
	
	if (fireTime >= FIRE_INTERVAL):
		get_node("SamplePlayer").play("shoot")
		var laser = preload("res://Assets/_Scenes/Laser.tscn").instance()
		laser.setMaxTravelTime(LASER_TRAVEL_TIME)
		laser.get_node("Sprite").set_modulate(Colour)
		if (get_node("Sprite").is_flipped_h()):
			laser.faceLeft = false
			if (lookingUp):
				laser.faceUp = true
				laser.set_pos((get_global_pos()) + Vector2(12,-14))
			else:
				laser.set_pos((get_global_pos()) + Vector2(22,8))
		else:
			if (lookingUp):
				laser.faceLeft = false
				laser.faceUp = true
				laser.set_pos((get_global_pos()) + Vector2(0,-14))
			else:
				laser.faceLeft = true
				laser.set_pos((get_global_pos()) + Vector2(-14,8))
		get_node("../../").add_child(laser)
		fireTime = 0
	else:
		fireTime += delta
			
func warp():
	warping = true
	if (!running or (velocity.x != 0)):
		get_node("SamplePlayer").play("dash")
		ghost()
		if (aliveTime >= DEATH_GRACE_PERIOD):
			aliveTime = 2.9
	if (!running):
		velocity.y = -JUMP_VELOCITY			
			
func moveLeft(var speed):
	movingLeft = true
	movingRight = false
	if (running):
		velocity.x = -speed
	else:
		if (get_node("Sprite").is_flipped_h()):
			get_node("Sprite").set_flip_h(false)
		if (!warping and (velocity.x > -speed)):
			velocity.x -= AIR_ACCEL
		else:
			velocity.x = -speed

func moveRight(var speed):
	movingLeft = false
	movingRight = true
	if (running):
		velocity.x = speed
	else:
		if !(get_node("Sprite").is_flipped_h()):
			get_node("Sprite").set_flip_h(true)
		if (!warping and (velocity.x < speed)):
			velocity.x += AIR_ACCEL
		else:
			velocity.x = speed
		
func handleAnimations():

	if (running):
		if (animationChange and (get_node("Sprite/AnimationPlayer").is_playing())):
			animPos = get_node("Sprite/AnimationPlayer").get_current_animation_pos()
			get_node("Sprite/AnimationPlayer").stop()
		if (velocity.x < 0):
			if (!get_node("Sprite/AnimationPlayer").is_playing()):
				if (lookingUp and shooting):
					get_node("Sprite/AnimationPlayer").play("runLeftGunUp")
				elif (shooting):
					get_node("Sprite/AnimationPlayer").play("runLeftGun")
				else:
					get_node("Sprite/AnimationPlayer").play("runLeft")
				
		elif (velocity.x > 0):
			if (!get_node("Sprite/AnimationPlayer").is_playing()):
				if (lookingUp and shooting):
					get_node("Sprite/AnimationPlayer").play("runRightGunUp")
				elif (shooting):
					get_node("Sprite/AnimationPlayer").play("runRightGun")
				else:
					get_node("Sprite/AnimationPlayer").play("runRight")
		else:
			if (get_node("Sprite/AnimationPlayer").is_playing()):
				get_node("Sprite/AnimationPlayer").stop(true)
			
			if (lookingUp and shooting and (get_node("Sprite").get_frame() != 9)):
				get_node("Sprite").set_frame(9)
			elif (!lookingUp and shooting and (get_node("Sprite").get_frame() != 8)):
				get_node("Sprite").set_frame(8)
			elif (!shooting and (get_node("Sprite").get_frame() != 0)):
				get_node("Sprite").set_frame(0)
			
		if (animationChange): 
			if (get_node("Sprite/AnimationPlayer").is_playing()):
				if (animPos >= (get_node("Sprite/AnimationPlayer").get_current_animation_length())):
					animPos -= 1
				get_node("Sprite/AnimationPlayer").seek(animPos, true)
			animationChange = false
			
	else:
		if (get_node("Sprite/AnimationPlayer").is_playing()):
			get_node("Sprite/AnimationPlayer").stop(true)
			
		if (velocity.y < 0):
			if (shooting and lookingUp and (get_node("Sprite").get_frame() != 22)):
				get_node("Sprite").set_frame(22)
			elif (shooting and !lookingUp and (get_node("Sprite").get_frame() != 20)):
				get_node("Sprite").set_frame(20)
			elif (!shooting and (get_node("Sprite").get_frame() != 6)):
				get_node("Sprite").set_frame(6)	
		else:
			if (shooting and lookingUp and (get_node("Sprite").get_frame() != 23)):
				get_node("Sprite").set_frame(23)
			elif (shooting and !lookingUp and (get_node("Sprite").get_frame() != 21)):
				get_node("Sprite").set_frame(21)
			elif (!shooting and (get_node("Sprite").get_frame() != 7)):
				get_node("Sprite").set_frame(7)
			
func checkCollisions(var delta, var motion):
	if (is_colliding()):
		var body = get_collider()
		if(body.get_parent().get_name() == "Enemies"):
			if (invincible or (body.opacity < 1)):
				body.destroy()
			else:
				respawn()
			
		var n  = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0,-1)))) == 0):
			running = true
			if (fallTime != 0):
				fallTime = 0
				get_node("SamplePlayer").play("land")
		elif (jumping):
			running = false
			if (fallTime != JUMP_GRACE_PERIOD):
				fallTime = JUMP_GRACE_PERIOD
			
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	else:
		running = false
		if (fallTime < JUMP_GRACE_PERIOD):
			fallTime += delta
			
func jumpLogic(var delta, var jump):
	if (jumping):
		if (jump and (jumpTime < JUMP_MAX_TIME) and (velocity.y < 0)):
			velocity.y = -JUMP_VELOCITY
			jumpTime += delta
		else:
			jumpTime = 0
			jumping = false
			if (velocity.y < 0):
				velocity.y += FALL_VELOCITY
	elif (jump and !prevJump and (running or (fallTime < JUMP_GRACE_PERIOD))):
		get_node("SamplePlayer").play("jump")
		jumping = true
		velocity.y = -JUMP_VELOCITY		
		
func respawn():
	velocity = Vector2(0, 0)
	fallTime = JUMP_GRACE_PERIOD
	running = false
	jumping = false
	aliveTime = 0
	flashTime = 0
	get_node("SamplePlayer").play("death")
	ghost()
	Global.addDeath()
	set_global_pos(checkPoint)
	
func finish():
	get_tree().change_scene("res://Assets/_Scenes/ScoreScreen.tscn")
	
func ghost():
	var ghost = preload("res://Assets/_Scenes/Ghost.tscn").instance()
	ghost.set_pos(get_global_pos())
	ghost.set_flip_h(get_node("Sprite").is_flipped_h())
	ghost.set_frame(get_node("Sprite").get_frame())
	get_node("../").add_child(ghost)
	
func setCheckPoint(var in_checkPoint):
	checkPoint = in_checkPoint
			