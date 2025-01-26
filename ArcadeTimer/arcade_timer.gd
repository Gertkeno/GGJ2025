class_name ArcadeTimer extends CanvasLayer

@onready var time_label: Label = $PanelContainer/MarginContainer/TimeLabel


func _ready() -> void:
	time_label.text = ""


func set_time(time_secs: int) -> void :
	@warning_ignore("integer_division")
	var minutes: int = time_secs / 60
	var seconds: int = time_secs % 60
	
	time_label.text = "Time: %d:%02d" % [minutes, seconds]
