extends Node2D

func set_digit(digit):
	for i in range(10):
		get_node(String(i)).visible = i == digit
