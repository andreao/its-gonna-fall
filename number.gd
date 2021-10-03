extends Node2D

var digit_scene

func _ready():
	 digit_scene = load("res://digit.tscn")

var digit_instances = []

func set_number(new_number):
	for digit_instance in digit_instances:
		digit_instance.queue_free()
	var x = 0
	while true:
		var digit = new_number % 10
		var digit_instance = digit_scene.instance()
		digit_instances.append(digit_instance)
		digit_instance.position = Vector2(x, 0)
		digit_instance.set_digit(digit)
		add_child(digit_instance)
		new_number /= 10
		x -= 30
		if new_number == 0:
			break

func _process(delta):
	
	pass
