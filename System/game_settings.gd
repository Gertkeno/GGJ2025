extends Control

signal continue_pressed

func _on_y_invert_toggled(toggle_on: bool) -> void:
	Player.y_invert = -1.0 if toggle_on else 1.0


func _on_camera_slider_value_changed(value: float) -> void:
	Player.camera_sensitivity = value


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	get_tree().paused = false
	continue_pressed.emit()
