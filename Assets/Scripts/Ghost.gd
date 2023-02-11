extends Sprite

func _ready():
	set_process(true)
	
func _process(delta):

	var opacity = get_opacity()
	
	if (opacity > 0):
		opacity -= delta*4
		set_opacity(opacity)
	else:
		destroy()
		
func destroy():
	set_process(false)
	queue_free()
		
	
