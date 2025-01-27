extends Control

signal continue_pressed
signal quit_pressed

func _on_y_invert_toggled(toggle_on: bool) -> void:
	Player.y_invert = -1.0 if toggle_on else 1.0


func _on_camera_slider_value_changed(value: float) -> void:
	Player.camera_sensitivity = value


func _on_quit_pressed() -> void:
	get_tree().paused = false
	quit_pressed.emit()


func _on_continue_pressed() -> void:
	get_tree().paused = false
	continue_pressed.emit()

	var rid := get_viewport().get_viewport_rid()
	var value: float = %RenderScale.value
	RenderingServer.viewport_set_scaling_3d_scale(rid, value)


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		%Continue.grab_focus()


func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_toggle_crouch_toggled(toggled_on: bool) -> void:
	Player.toggle_crouch = toggled_on


func _on_fullscreen_toggled(toggle_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggle_on else DisplayServer.WINDOW_MODE_WINDOWED)
