extends Node2D

var opacity = 1

func _ready():
	get_node("Score").set_text(get_node("Score").get_text() + str(Global.score))
	get_node("Kills").set_text(get_node("Kills").get_text() + str(Global.kills))
	get_node("Deaths").set_text(get_node("Deaths").get_text() + str(Global.deaths))
	get_node("SamplePlayer").play("win")
	set_process(true)
	
func _process(delta):
	
	if (opacity > 0):
		opacity -= delta/3
		set_opacity(opacity)
	else:
		get_tree().change_scene("res://Assets/_Scenes/TitleMenu.tscn")