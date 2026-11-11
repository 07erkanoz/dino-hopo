extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var scene = load("res://scenes/nature_workspace.tscn").instantiate()
	root.add_child(scene)
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://art/planning/01-map-overview.png")
	assert(error == OK)
	print("PASS: native map-only workspace overview captured")
	quit(0)
