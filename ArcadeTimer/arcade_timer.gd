class_name ArcadeTimer extends CanvasLayer

@onready var time_label: Label = $PanelContainer/MarginContainer/TimeLabel
@export var critical_bound := 30
@export var critical_color: Color = Color.DARK_RED

var critical_time_entered := false

func _ready() -> void:
	time_label.text = ""
	time_label.add_theme_color_override("Font Color", Color.WHITE)


func set_time(time_secs: int) -> void :
	@warning_ignore("integer_division")
	
	if time_secs < critical_bound and not critical_time_entered:
		_start_critical_flashing()
	
	var minutes: int = time_secs / 60
	var seconds: int = time_secs % 60
	
	time_label.text = "Time: %d:%02d" % [minutes, seconds]
	

func _start_critical_flashing() -> void:
	critical_time_entered = true
	var tween := time_label.create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(time_label, "theme_override_colors/font_color", critical_color, 0.5).from(Color.WHITE)
	tween.tween_property(time_label, "theme_override_colors/font_color", Color.WHITE, 0.5).from(critical_color)
