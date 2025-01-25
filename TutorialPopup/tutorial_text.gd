@tool
extends Node3D


@export_placeholder("Name of action") var action_text: String:
	set(v):
		if Engine.is_editor_hint() and get_node_or_null("Label3D"):
			$Label3D.text = v + action_icon
		action_text = v
@export_placeholder("Font icon") var action_icon: String


func _ready() -> void:
	if not Engine.is_editor_hint():
		$Label3D.text = tr(action_text) + " " + action_icon
	else:
		$Label3D.text = action_text + " " + action_icon
