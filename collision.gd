extends Object
class_name CollisionHandler

signal path_changed(path)

var collisions = []

var source
var target
	
var box_scene
func _init(box_scene):
	self.box_scene = box_scene

func collision_entered(body1, body2):
	for collision in collisions:
		if _connects(collision, body1, body2):
			return
	collisions.append([body1, body2])

func collision_exited(body1, body2):
	var new_collisions = []
	for collision in collisions:
		if not _connects(collision, body1, body2):
			new_collisions.append(collision)
	collisions = new_collisions

func _connects(collision, body1, body2):
	return (collision[0] == body1 and collision[1] == body2) or (collision[1] == body1 and collision[0] == body2)
	
func find_path():
	var path = []
	var queue = [source]
	while len(queue) > 0:
		var body = queue.pop_front()
		if body in path:
			continue
		if _is_box(body):
			if body.dragging or body.locked:
				continue
		else:
			if body != source and body != target:
				continue
		path.append(body)
		if body == target:
			break
		for other_collision in collisions:
			if other_collision[0] == body:
				queue.push_back(other_collision[1])
			elif other_collision[1] == body:
				queue.push_back(other_collision[0])
	emit_signal("path_changed", path)

func _is_box(body):
	return body.get_filename() == box_scene.get_path()

func trim_boxes(boxes):
	var new_collisions = []
	for collision in collisions:
		var include = false
		for body in collision:
			if body in boxes or body == source or body == target:
				include = true
		if include:
			new_collisions.append(collision)
	collisions = new_collisions
