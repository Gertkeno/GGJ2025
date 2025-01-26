extends Control


@export_file("*.tscn") var main_menu_path = "res://main_menu.tscn"
@export_file("*.txt") var credits_file = "res://credits.txt"
@export var credit_theme: Theme
@export var scroll_speed := 1.0
@export var scroll_delay := 3.0

@onready var back_button := $MarginContainer/VBoxContainer/ButtonContainer/Back
@onready var credits_container := $MarginContainer/VBoxContainer/ScrollContainer/CreditsContainer

var start_scrolling: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_credits()
	back_button.grab_focus()
	_start_delay_timer()


func _physics_process(delta: float) -> void:
	if not start_scrolling:
		return
	
	var scroll = scroll_speed * delta
	credits_container.position.y -= scroll
	

func _build_credits() -> void:
	var content = FileAccess.open(credits_file, FileAccess.READ).get_as_text()
	var credits_list = content.rsplit("\n", true)
	
	for credit_txt in credits_list:
		var credit_node = Label.new()
		credit_node.text = credit_txt
		credit_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		credit_node.theme = credit_theme
		
		credits_container.add_child(credit_node)
		

func _start_delay_timer() -> void:
	start_scrolling = false
	var start_scroll_timer := Timer.new()
	add_child(start_scroll_timer)
	start_scroll_timer.one_shot = true
	start_scroll_timer.timeout.connect(_on_start_scroll_timer_timeout)
	start_scroll_timer.start(scroll_delay)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)


func _on_start_scroll_timer_timeout() -> void:
	start_scrolling = true
