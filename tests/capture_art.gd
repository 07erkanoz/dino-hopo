extends SceneTree
## Run with a rendering display, not --headless. Saves actual viewport screenshots.
## godot --path . --script tests/capture_art.gd

func _initialize() -> void:
	call_deferred("capture")

func shot(path: String) -> void:
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image.is_empty():
		push_error("Renderer returned an empty screenshot; a rendering display is required")
		quit(1)
		return
	var error := image.save_png(path)
	assert(error == OK, "Could not save screenshot")

func capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await shot("res://art/review/menu-in-engine.png")
	game.show_character_select(2)
	await shot("res://art/review/character-select-in-engine.png")
	game.start_game(2)
	for i in 90:
		await physics_frame
	await shot("res://art/review/gameplay-in-engine.png")
	for player in game.players: player.position = Vector2(2650 + player.slot * 90, 500)
	await shot("res://art/review/waterfall-in-engine.png")
	game.show_gallery()
	await shot("res://art/review/heroes-in-engine.png")
	var tabs: TabContainer = game.overlay.get_child(game.overlay.get_child_count() - 1).get_child(2)
	tabs.current_tab = 3
	await shot("res://art/review/creatures-in-engine.png")
	print("PASS: saved six native Godot viewport captures")
	quit(0)
