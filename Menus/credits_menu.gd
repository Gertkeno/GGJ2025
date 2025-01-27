class_name CreditsScreen extends Control


@export_file("*.tscn") var main_menu_path: String = "res://main_menu.tscn"
@export_file("*.txt") var credits_file: String = "res://credits.txt"
@export var credit_theme: Theme
@export var scroll_speed := 1.0
@export var scroll_delay := 3.0

@onready var back_button := $MarginContainer/VBoxContainer/ButtonContainer/Back
@onready var credits_container := $MarginContainer/VBoxContainer/ScrollContainer/CreditsContainer
@onready var score_display := $MarginContainer/VBoxContainer/ScoreDisplay
@onready var music := $AudioStreamPlayer2D

var start_scrolling: bool
var score: int = -1
var creature_list: Array[AnimalDescriptor]
var start_scroll_timer: Timer

static var from_game := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_end_level_stats([AnimalDescriptor.new("test", Color.RED, AnimalDescriptor.Type.NEUTRAL)], 20.0)
	start_scroll_timer = Timer.new()
	start_scroll_timer.one_shot = true
	start_scroll_timer.timeout.connect(_on_start_scroll_timer_timeout)
	add_child(start_scroll_timer)
	if not from_game:
		start_credits()
		CreditsScreen.from_game = true


func _process(delta: float) -> void:
	if not start_scrolling:
		return
	
	var scroll: float = scroll_speed * delta
	credits_container.position.y -= scroll


func set_end_level_stats(creatures: Array[AnimalDescriptor], time_left: float) -> void:
	self.creature_list = creatures
	self.score = _calculate_score(creatures, time_left)


func start_credits() -> void:
	music.play()
	back_button.grab_focus()
	_build_credits()
	_start_delay_timer()


func reset_credits() -> void:
	start_scrolling = false
	credits_container.position.y = 0
	
	for child: Node in credits_container.get_children():
		credits_container.remove_child(child)


static func _calculate_score(creatures: Array[AnimalDescriptor], time_left: float) -> int:
	var calculated_score: int = 0
	
	for animal_descriptor in creatures:
		var animal_value: int = 0
		match animal_descriptor.type:
			AnimalDescriptor.Type.SKITTISH:
				animal_value += 20
			AnimalDescriptor.Type.NEUTRAL:
				animal_value += 5
			AnimalDescriptor.Type.DEFENSIVE:
				animal_value += 50
			_:
				pass
		animal_value = int(animal_value * (animal_descriptor.rating  * 4 + 1))
		calculated_score += animal_value

	calculated_score += int(0.5 * time_left)
	calculated_score *= 100
		
	return calculated_score


func _build_credits() -> void:
	if score < 0:
		score_display.text = "Thanks for Playing!"
	else:
		score_display.text = "Congratulations you scored %d points" % score
	
	var content := FileAccess.open(credits_file, FileAccess.READ).get_as_text()
	var credits_list := content.rsplit("\n", true)
	
	for credit_txt: String in credits_list:
		var credit_node := Label.new()
		credit_node.text = credit_txt
		credit_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		credit_node.theme = credit_theme
		credit_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		credits_container.add_child(credit_node)
		
	if len(creature_list) > 0:
		var creature_title := Label.new()
		
		creature_title.text = "Creatures Caught"
		creature_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		creature_title.theme = credit_theme
		creature_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		credits_container.add_child(creature_title)

	for animal: AnimalDescriptor in creature_list:
		var creature_title := RichTextLabel.new()
		var creature_text: String  = "[center]%s: [color=%x]%s type[/color][/center]" % [animal.name, animal.color.to_rgba32(), AnimalDescriptor.Type.keys()[animal.type]]
		print(creature_text)
		creature_title.text = creature_text
		creature_title.bbcode_enabled = true
		creature_title.theme = credit_theme
		creature_title.fit_content = true
		creature_title.clip_contents = false
		creature_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		credits_container.add_child(creature_title)
		
	_reset_position.call_deferred()


func _reset_position() -> void:
	credits_container.position.y = 0


func _start_delay_timer() -> void:
	start_scrolling = false
	start_scroll_timer.start(scroll_delay)


func _on_back_pressed() -> void:
	print("Going back to menu")
	music.stop()
	get_tree().change_scene_to_file(main_menu_path)


func _on_start_scroll_timer_timeout() -> void:
	start_scrolling = true
