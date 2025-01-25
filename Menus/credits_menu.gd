extends VBoxContainer


@export_file("*.tscn") var main_menu_path = "res://main_menu.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Back.grab_focus()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)
