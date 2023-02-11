extends Node2D

var opacity = 0
var selection = 2

var prevUp = false
var prevDown = false
var prevSelect = false
var prevQuit = false
var leaving = false
var main = true

func _ready():
	get_node("Main/Subtitle/AnimationPlayer").play("flash")
	set_process(true)
	
func _process(delta):

	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var select = Input.is_action_pressed("singlePlayer_jump")
	var quit = Input.is_action_pressed("ui_cancel")
	
	if ((!leaving) and (opacity < 1)):
		opacity += delta/1.5
		if (main):
			get_node("Main").set_opacity(opacity)
		else:
			get_node("Controls").set_opacity(opacity)
	elif ((leaving) and (opacity > 0)):
		opacity -= delta/3
		if (main):
			get_node("Main").set_opacity(opacity)
			get_node("StreamPlayer").set_volume(opacity)
		else:
			get_node("Controls").set_opacity(opacity)
			
	elif (!leaving):
		
		var sample = get_node("SamplePlayer")
		var tex = get_node("Main").get_child(selection)
		if (!tex.get_node("AnimationPlayer").is_playing()):	
			tex.get_node("AnimationPlayer").play("flash")	
		
		if (up and !prevUp):
			if (main):
				sample.play("menu_move")
				tex.get_node("AnimationPlayer").play("idle")
				if (selection > 2):
					selection -= 1
				else:
					selection = 5
			else:
				backToMain()
		elif (down and !prevDown):
			if (main):
				sample.play("menu_move")
				tex.get_node("AnimationPlayer").play("idle")
				if (selection < 5):
					selection += 1
				else:
					selection = 2
			else:
				backToMain()
		elif (select and !prevSelect):
			if (main):
				if (selection != 5):
					sample.play("menu_select")
				else:
					sample.play("menu_back")
				if (selection != 4):
					leaving = true
				else:
					get_node("Main").hide()
					get_node("Controls").show()
					main = false
			else:
				backToMain()
		elif (quit and !prevQuit):
			sample.play("menu_back")
			selection = 5
			leaving = true
				
		prevUp = up
		prevDown = down
		prevSelect = select
		prevQuit = quit
				
	else:
		if (selection == 2):
			Global.setSinglePlayer(true)
			Global.resetScore()
			get_tree().change_scene("res://Assets/_Scenes/Level1.tscn")
		elif (selection == 3):
			Global.setSinglePlayer(false)
			Global.resetScore()
			get_tree().change_scene("res://Assets/_Scenes/Level1.tscn")
		elif (selection == 5):
			get_tree().quit()
			
func backToMain():
	get_node("SamplePlayer").play("menu_back")
	get_node("Controls").hide()
	get_node("Main").show()
	main = true
			
	