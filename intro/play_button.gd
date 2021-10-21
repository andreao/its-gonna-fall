extends TextureButton

func _on_play_button_button_down():
	$AnimationPlayer.stop()
	$press_sound.play()
func _on_play_button_button_up():
	$AnimationPlayer.play()
func _on_play_button_pressed():
	$release_sound.play()
