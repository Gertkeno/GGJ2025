extends VBoxContainer

@export_file("*.tscn") var main_scene_path: String = "res://bubble_world_map.tscn"
@export_file("*.tscn") var credits_scene_path: String = "res://credits_screen.tscn"

@onready var music = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.play()
	$Start.grab_focus()
	ResourceLoader.load_threaded_request(main_scene_path)


func _on_exit_pressed() -> void:
	music.stop()
	get_tree().quit()


func _on_start_pressed() -> void:
	music.stop()
	var tree: SceneTree = get_tree()
	tree.paused = false
	Player.arcade_mode = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var main_scene := ResourceLoader.load_threaded_get(main_scene_path)
	tree.change_scene_to_packed(main_scene)


func _on_freeplay_pressed() -> void:
	music.stop()
	var tree: SceneTree = get_tree()
	tree.paused = false
	Player.arcade_mode = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var main_scene := ResourceLoader.load_threaded_get(main_scene_path)
	tree.change_scene_to_packed(main_scene)


func _on_credits_pressed() -> void:
	music.stop()
	CreditsScreen.from_game = false
	get_tree().change_scene_to_file(credits_scene_path)
