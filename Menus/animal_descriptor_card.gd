extends Control

func set_data(data: AnimalDescriptor) -> void:
	$Name.text = data.name
	$Description.text = data.description
	$Name.set("theme_override_colors/font_color", data.color)
	$Rating/ProgressBar.value = data.rating
	$Type.text = "Type: %s" % AnimalDescriptor.Type.keys()[data.type]
