extends Area3D

@export_range(1.0, 20.0, 0.1) var force: float = 7.0
const PRICKED = preload("res://Assets/Particles/pricked_particles.tscn")

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var diff: Vector3 = body.global_position - global_position
		var direction := Vector2(diff.x, diff.z).normalized() #flat
		body.knockback(Vector3(direction.x, 0, direction.y) * force)

	elif body is BubbleAnimal:
		var prick_fx: GPUParticles3D = PRICKED.instantiate()
		get_tree().root.add_child(prick_fx)
		prick_fx.global_position = body.global_position
		prick_fx.emitting = true
		prick_fx.finished.connect(prick_fx.queue_free)

		body.get_parent().get_parent().queue_free()
