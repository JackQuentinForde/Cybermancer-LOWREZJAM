extends Node2D

const MAX_DEAD_TIME = 25
const MIN_PLAYER_DIST = 48

var enemiesList = []
var enemiesDeadTimes = []
var blocked = false

func _ready():
	enemiesList.resize(get_child_count())
	for i in range(enemiesList.size()):
		enemiesList[i] = get_child(i)
	enemiesDeadTimes.resize(enemiesList.size())
	for i in range(enemiesDeadTimes.size()):
		enemiesDeadTimes[i] = 0
	set_process(true)
	
func _process(delta):
	if (enemiesList.size() > get_child_count()):
		for i in range(enemiesList.size()):
			if (!enemiesList[i].is_inside_tree()):
				if (enemiesDeadTimes[i] < MAX_DEAD_TIME):
					enemiesDeadTimes[i] += delta
				else:
					for j in range (get_node("../Players").get_child_count()):
						if (enemiesList[i].spawnLocation.distance_to(get_node("../Players").get_child(j).get_global_pos()) < MIN_PLAYER_DIST):
							blocked = true
					if (!blocked):
						add_child(enemiesList[i])
						enemiesDeadTimes[i] = 0
					else:
						blocked = false
	else:
		pass
