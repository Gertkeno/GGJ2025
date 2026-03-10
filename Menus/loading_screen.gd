extends Control

# This is a horrible script, godot threaded loading does not work very well
# blocked almost entirely by single threaded rendering pipeline with no
# notifications on progress.


## Mark true when placed in main scene, this node will show 100% and fade out
@export var is_post_load: bool = false

## What to load
@export_file("*.tscn") var main_scene_path: String

func _ready() -> void:
	if is_post_load:
		%ProgressBar.show()
		%ProgressBar.value = 100
		set_process(false)
		var t := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(self, "modulate:a", 0, 1.0)
		await t.finished

		queue_free()
		return


	var success := ResourceLoader.load_threaded_request(main_scene_path, "PackedScene", true)
	if success != OK:
		push_warning("failed to thread load request, just send it lol")
		var tree := get_tree()
		await tree.process_frame
		tree.change_scene_to_file(main_scene_path)


func _process(_delta: float) -> void:
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(main_scene_path, progress)

	if ResourceLoader.THREAD_LOAD_LOADED:
		var next: PackedScene = ResourceLoader.load_threaded_get(main_scene_path)
		print("Done loading! ", next)
		%ProgressBar.value = 50
		set_process(false)
		var tree := get_tree()
		await tree.process_frame
		tree.change_scene_to_packed(next)
	elif ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		print("Still loading! ", progress[0])
		%ProgressBar.value = progress[0] * 50
	else:
		push_warning("Something failed during load ", status)
		get_tree().change_scene_to_file(main_scene_path)
