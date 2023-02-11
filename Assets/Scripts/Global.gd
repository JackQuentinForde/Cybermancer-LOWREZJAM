extends Node

var score = 0
var deaths = 0
var kills = 0
var singlePlayer = true

func setSinglePlayer(var boolean):
	singlePlayer = boolean 
	
func resetScore():
	score = 0
	deaths = 0
	kills = 0
	
func addScore(var in_points):
	score += in_points
	
func addKill():
	kills += 1
	
func addDeath():
	deaths += 1