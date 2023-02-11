extends Node2D

var prevPause = false
var prevUp = false
var prevDown = false
var prevSelect = false
var paused = false
var selection = 0

func _ready():
	set_process(true)

func _process(delta):
	
	var pause = Input.is_action_pressed("ui_cancel")

	if (pause and !prevPause):
		if (paused):
			get_node("SamplePlayer").play("menu_select")
		else:
			get_node("SamplePlayer").play("menu_back")
		pause()
			
	if (paused):
	
		var up = Input.is_action_pressed("ui_up")
		var down = Input.is_action_pressed("ui_down")
		var select = Input.is_action_pressed("singlePlayer_jump")
		
		var tex = get_node("PauseMenu").get_child(selection)
		
		if (selection == 0):
			if (!tex.get_node("AnimationPlayer").is_playing()):
				tex.get_node("AnimationPlayer").play("flash")
		else:
			if (!tex.get_node("AnimationPlayer").is_playing()):
				tex.get_node("AnimationPlayer").play("flash")
				
		if (up and !prevUp):
			get_node("SamplePlayer").play("menu_move")
			tex.get_node("AnimationPlayer").play("idle")
			if (selection == 1):
				selection = 0
			else:
				selection = 1
				
		if (down and !prevDown):
			get_node("SamplePlayer").play("menu_move")
			tex.get_node("AnimationPlayer").play("idle")
			if (selection == 0):
				selection = 1
			else:
				selection = 0
		
		if (select and !prevSelect):
			pause()
			if (selection == 0):
				get_node("SamplePlayer").play("menu_select")
			else:
				get_tree().change_scene("res://Assets/_Scenes/TitleMenu.tscn")
	
		prevUp = up
		prevDown = down
		prevSelect = select
		
	prevPause = pause
	
func pause():
	if (!paused):
		get_tree().set_pause(true)
		get_node("Game").hide()
		get_node("PauseMenu").set_global_pos(get_node("Game/Players/CameraFocus").get_global_pos())
		get_node("PauseMenu").show()
		selection = 0
		paused = true
	else:
		get_tree().set_pause(false)
		get_node("PauseMenu").hide()
		if (Global.singlePlayer):
			get_node("Game/Players/Player1").prevJump = true
		get_node("Game").show()
		paused = false