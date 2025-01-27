extends Area3D


@export var respawn_pos: Marker3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.velocity = Vector3.ZERO
		var last_jump_pos: Vector3 = body.get_meta("last_jump", Vector3.ZERO)
		if last_jump_pos:
			body.position = last_jump_pos
		else:
			body.position = respawn_pos.position
