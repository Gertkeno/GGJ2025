extends Control


@export_file("*.tscn") var main_menu_path = "res://main_menu.tscn"
@export var scroll_speed := 1.0

@onready var back_button := $MarginContainer/VBoxContainer/ButtonContainer/Back
@onready var credits_container := $MarginContainer/VBoxContainer/ScrollContainer/CreditsContainer
@onready var start_scroll_timer := $StartScrollTimer

var start_scrolling: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.grab_focus()
	start_scrolling = false
	start_scroll_timer.start()


func _physics_process(delta: float) -> void:
	if not start_scrolling:
		return
	
	var scroll = scroll_speed * delta
	credits_container.position.y -= scroll


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)


func _on_start_scroll_timer_timeout() -> void:
	start_scrolling = true
