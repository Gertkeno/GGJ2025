extends Area3D

@export_range(1.0, 20.0, 0.1) var force: float = 7.0

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var diff: Vector3 = body.global_position - global_position
		var direction := Vector2(diff.x, diff.z).normalized() #flat
		body.knockback(Vector3(direction.x, 0, direction.y) * force)

	elif body is BubbleAnimal:
		pass # delete the bubble beast
		body.get_parent().get_parent().queue_free()
