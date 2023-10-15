extends Node2D

var holding = null
var timeTillYarnBall = 1.0
@export var interval = 0.5
@onready var yarn_ball: PackedScene = preload("res://yarn_ball.tscn")
@export var sad_song: AudioStream = preload("res://Music/sad_theme.ogg")
var totalYarnBalls = 0
var gameEnded = false
var gameEndedTime = 0
var priorHighScore = null

func _init():
	priorHighScore = load_value("HighScore")

func _process(_delta):
	if gameEnded:
		gameEndedTime += get_process_delta_time()
		if gameEndedTime > 2:
			if !$UI/YouLost/Button.visible:
				$UI/YouLost/Button.visible = true
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$Hand.position = get_global_mouse_position()
	else:
		$Hand.position = Vector2(0,10000)
	timeTillYarnBall -= get_process_delta_time()
	if timeTillYarnBall <= 0.0:
		timeTillYarnBall += interval
		var newYarn = yarn_ball.instantiate()
		newYarn.master = self
		add_child(newYarn)
		newYarn.position = Vector2.ZERO
		totalYarnBalls += 1
		if priorHighScore != null:
			$UI/Score.text = "Score: %s\nHigh Score: %s" % [totalYarnBalls, priorHighScore]
		else:
			$UI/Score.text = "Score: %s" % totalYarnBalls

func _grabed_object(grabed_object):
	holding = grabed_object
	
func _droped_object():
	holding = null

func _game_ended():
	if gameEnded:
		return
	gameEnded = true
	$Enviroment/AudioStreamPlayer2D.stream = sad_song
	$Enviroment/AudioStreamPlayer2D.play()
	$UI/YouLost.visible = true
	if priorHighScore != null:
		if totalYarnBalls > priorHighScore:
			$UI/YouLost/Score2.text = "Your Score: %s
				Old High Score: %s
				New High Score!" % [totalYarnBalls, priorHighScore]
			save_value("HighScore", totalYarnBalls)
		else:
			$UI/YouLost/Score2.text = "Your Score: %s
				High Score: %s" % [totalYarnBalls, priorHighScore]
	else:
		save_value("HighScore", totalYarnBalls)
		$UI/YouLost/Score2.text = "Your Score: %s" % totalYarnBalls
	
	

func save_value(value_name, value):
	var config = ConfigFile.new()
	config.set_value("Game", value_name, value)
	config.save("user://config.cfg")  # Save to a user-specific configuration file

func load_value(value_name):
	var config = ConfigFile.new()
	if config.load("user://config.cfg") == OK:
		if config.has_section("Game") and config.has_section_key("Game", value_name):
			return config.get_value("Game", value_name)
	return null

func _restart_button_pressed():
	if gameEndedTime < 2:
		return
	get_tree().reload_current_scene()
	pass # Replace with function body.
