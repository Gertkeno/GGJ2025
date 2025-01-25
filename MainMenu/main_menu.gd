extends VBoxContainer

@export_file("*.tscn") var main_scene_path = "res://bubble_world_map.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Start.grab_focus()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(main_scene_path)
