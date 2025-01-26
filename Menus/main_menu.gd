extends VBoxContainer

@export_file("*.tscn") var main_scene_path: String = "res://bubble_world_map.tscn"
@export_file("*.tscn") var credits_scene_path: String = "res://credits_screen.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Start.grab_focus()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	var tree: SceneTree = get_tree()
	tree.paused = false
	Player.arcade_mode = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	tree.change_scene_to_file(main_scene_path)


func _on_freeplay_pressed() -> void:
	var tree: SceneTree = get_tree()
	tree.paused = false
	Player.arcade_mode = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	tree.change_scene_to_file(main_scene_path)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(credits_scene_path)
