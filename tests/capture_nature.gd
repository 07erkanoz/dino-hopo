extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var scene = load("res://scenes/nature_workspace.tscn").instantiate()
	root.add_child(scene)
	for i in 5: await process_frame
	scene.overlay.visible = false
	for item in [[0,"grove"],[1,"roots"],[3,"falls"],[4,"cave"]]:
		scene.focus_region(item[0])
		for i in 4: await process_frame
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png("res://art/nature/review-"+item[1]+".png")
		assert(error==OK)
	scene.overlay.visible = true
	scene.show_nature = false
	scene.nature.visible = false
	scene.build_ui()
	scene.overview()
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://art/planning/01-map-overview.png")
	assert(error == OK)
	print("PASS: four native nature-only views and current map captured")
	quit(0)
