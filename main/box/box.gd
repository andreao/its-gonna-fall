extends RigidBody2D

var connected = false
var locked = false
var emotion = "smiling"
var dragging = false

# Drag and drop
func is_draggable():
	return not locked and not dragging
func drag():
	dragging = true
	mode = RigidBody2D.MODE_KINEMATIC
	emotion == "smiling"
	$grab_sound.play()
func drop():
	dragging = false
	mode = RigidBody2D.MODE_RIGID
	linear_velocity /= 10
	can_sleep = false # since drag&drop a still box needs to kick start the physics engine
	get_node("CollisionShape2D").disabled = false
	$place_sound.play()


func _physics_process(delta):
	if not locked and not dragging:
		var velocity = linear_velocity.length()
		if velocity > 100:
			if emotion != "scared":
					$fall_sound.play()
			emotion = "scared"
		elif velocity > 10:
			emotion = "worried"
		else:
			emotion = "smiling"
func lock():
	locked = true
	emotion = "happy"
	set_deferred("mode", RigidBody2D.MODE_STATIC)

func _process(delta):
	$overlay.visible = not connected
	for old_emotion in ["smiling", "worried", "happy", "scared"]:
		get_node(old_emotion).visible = old_emotion == emotion

var mouse_hover = false
func is_hovering():
	return mouse_hover
func _on_CollisionShape2D_mouse_entered():
	   mouse_hover = true
func _on_CollisionShape2D_mouse_exited():
	   mouse_hover = false
