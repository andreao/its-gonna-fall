extends Node2D

var box_scene = preload("box/box.tscn")
var line_scene = preload("line.tscn")
var box_instance:RigidBody2D # currently instantiating
var collision_handler:CollisionHandler
var box_instances = []

var line_index = 0
var line_heights = []

func _ready():	
	# initialize some stupid "levels"
	var y = 0
	var dy = -1000
	for i in range(1000):
		line_heights.append(y)
		y += dy
		dy -= 500

	collision_handler = CollisionHandler.new(box_scene)
	collision_handler.target = $ground
	collision_handler.connect("path_changed", self, "_path_changed")
	next_line()
	_move_camera_to_highest(true)

func next_line():
	var line_instance = line_scene.instance()
	line_instance.position = Vector2(0, line_heights[line_index])
	add_child(line_instance)
	collision_handler.source = collision_handler.target
	collision_handler.target = line_instance
	$camera/score.set_number(line_index)
	line_index += 1

var outside = []

func _path_changed(path):
	for body in box_instances:
		if not body.locked:
			body.connected = body in path
	if collision_handler.target in path:
		for box_instance in box_instances:
			if box_instance in path:
				box_instance.lock()
		
		# cleanup for performance
		var new_boxes = []
		for box_instance in box_instances:
			if box_instance in outside:
				box_instance.queue_free()
			elif not box_instance.locked:
				new_boxes.append(box_instance)				
		box_instances = new_boxes
		collision_handler.trim_boxes(box_instances)
		
		next_line()
		_move_camera_to_highest(true)
		$camera/hurray.play()
	
func _get_collisions_at(position):
	for collision in get_world_2d().direct_space_state.intersect_point(position, 1):
		return collision["collider"]
	return null

var drag_offset

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	if Input.is_action_just_pressed("place"):
		var hovered = _get_collisions_at(mouse_position)
		if hovered != null and not hovered.get_filename() == line_scene.get_path():
			if hovered in box_instances and hovered.is_draggable():
				box_instance = hovered
				drag_offset = mouse_position
		else:
			box_instance = box_scene.instance()
			box_instance.position = mouse_position
			drag_offset = mouse_position
			box_instance.connect("body_entered", collision_handler, "collision_entered", [box_instance])
			box_instance.connect("body_exited", collision_handler, "collision_exited", [box_instance])
			box_instance.connect("body_entered", self, "_box_collision", [box_instance])
			box_instance.get_node("VisibilityNotifier2D").connect("screen_exited", self, "_screen_exited_handler", [box_instance])
			add_child(box_instance)
		if box_instance != null:
			box_instance.drag()
	elif Input.is_action_pressed("place"):
		if box_instance != null:
			box_instance.position += (mouse_position - drag_offset)
			drag_offset = mouse_position
	else:
		if box_instance != null:
			box_instance.drop()
			box_instances.append(box_instance)
			box_instance = null
	# apply some random forces
	#for box_instance in box_instances:
	#	box_instance.applied_torque = (randf() - 0.5) * 100000*delta
	#	box_instance.applied_force = Vector2((randf() - 0.5) * 100000*delta, 0)

func _move_camera_to_highest(force):
	var max_height = min(300, collision_handler.source.position.y)
	for body in box_instances:
		if (body.connected or body.locked) and body.position.y < max_height:
			max_height = body.position.y
	var position = Vector2(0, max_height)
	var height_diff = $camera.position.y - position.y
	var line_height = collision_handler.source.position.y - 600
	if abs(height_diff) > 500 or $camera.position.y >= line_height:
		var tween = $camera_transition_tween
		if force:
			tween.stop_all()
		if not tween.is_active():
			var height = min($camera.position.y - sign(height_diff)*200, line_height)
			tween.remove_all()
			tween.interpolate_property($camera, "position", null, 
				Vector2(0, height), 2, Tween.TRANS_CUBIC)
			tween.start()
	
func _process(delta):
	_move_camera_to_highest(false)
	collision_handler.find_path()
	_handle_collision_audio()
	
# Remove boxes for performance reasons
func _screen_exited_handler(body):
	outside.append(body)


var recent_collisions = []
func _box_collision(body, other_body):
	recent_collisions.append(other_body)
func _handle_collision_audio():
	var count = 0
	for box in box_instances:
		var audio_player = box.get_node("thud_sound")
		if audio_player.playing:
			count += 1
	for body in recent_collisions:
		if count < 10:
			var audio_player = body.get_node("thud_sound")
			if not audio_player.playing:
				audio_player.play()
				count += 1
	recent_collisions.clear()
