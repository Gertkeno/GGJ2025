@tool
extends EditorScript

## INSTRUCTIONS
# Open res://Environment/Map/bubble_world_map.tscn; press run
#
# Only CSG gizmos are sadly drawn in the sub viewport, changes to each animal's
# bubble color is not reflected in git


var cycleref: EditorScript

func _run() -> void:
	cycleref = self
	var root := get_scene()
	var animals: Array = root.get_tree().get_nodes_in_group("Bubble Beasties")

	print("Got animals list")

	var subviewport := SubViewport.new()
	subviewport.size = Vector2i(128, 128)
	subviewport.msaa_3d = Viewport.MSAA_4X
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var thumbnail_camera := Camera3D.new()
	thumbnail_camera.fov = 40
	thumbnail_camera.rotation.y = deg_to_rad(-160)
	thumbnail_camera.rotation.x = deg_to_rad(-20)

	subviewport.add_child(thumbnail_camera)
	print("Adding thumbnailer subviewport")
	root.add_child(subviewport)
	subviewport.owner = root
	thumbnail_camera.owner = root

	await RenderingServer.frame_post_draw
	thumbnail_camera.make_current()
	for animal: BubbleAnimal in animals:
		var grand_parent: Node3D = animal.get_parent().get_parent()
		var descriptor: AnimalDescriptor = grand_parent.descriptor

		var bubble_material: ShaderMaterial = animal.visual_mesh.get_surface_override_material(0)
		bubble_material.set_shader_parameter("rim_color", descriptor.color)
		var low_alpha: Color = descriptor.color
		low_alpha.a = 0.4
		bubble_material.set_shader_parameter("tint_color", low_alpha)

		thumbnail_camera.global_transform = grand_parent.global_transform
		thumbnail_camera.translate_object_local(Vector3(-4, 4, -4))
		thumbnail_camera.rotation += Vector3(deg_to_rad(-30), deg_to_rad(-135), 0)

		await RenderingServer.frame_post_draw

		var file_name: String = "res://Animals/Pictures/%d.png" % hash(descriptor.name)
		print ("saving: ", file_name)
		var animal_image := subviewport.get_texture().get_image()
		animal_image.save_png(file_name)

	subviewport.queue_free()
	cycleref = null
