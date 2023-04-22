extends "res://targets/target.gd"

func _process(delta):
	position = position.posmodv(screen)
