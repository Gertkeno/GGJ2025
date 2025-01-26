class_name ArcadeTimer extends CanvasLayer

@onready var time_label = $PanelContainer/MarginContainer/TimeLabel


func set_time(time_secs: int) -> void :
	var minutes = time_secs / 60
	var seconds = time_secs % 60
	
	time_label.text = "Time: %d:%02d" % [minutes, seconds]
