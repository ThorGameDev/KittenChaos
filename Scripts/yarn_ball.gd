extends Node2D

var isHeald = false
@export var speed = 0
var master = null

func _process(delta):
	if !isHeald:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and master.holding == null:
			if get_global_mouse_position().distance_to(position) < 55:
				isHeald = true
				master._grabed_object(self)
		var escape = position.normalized()
		if escape == Vector2.ZERO:
			escape = Vector2(randf_range(-1, 1), randf_range(-1, 1))
		position += escape * delta * speed
	else:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			position = get_global_mouse_position()
		else:
			isHeald = false
			master._droped_object()


func _exited_screen():
	master._game_ended()
