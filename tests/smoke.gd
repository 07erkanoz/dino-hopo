extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
		assert(condition, message)

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	check(game.tr_text("solo") == "Tek oyuncu", "Turkish text missing")
	game.language = "en"
	check(game.tr_text("solo") == "One player", "English text missing")
	game.start_game(2)
	await process_frame
	await process_frame
	check(game.players.size() == 2, "Two players did not spawn")
	check(game.berries.size() == game.level.fruit.size(), "Collectible layout changed unexpectedly")
	for i in 90:
		await physics_frame
	for player in game.players:
		check(player.is_on_floor(), "Player failed to land on terrain")
		check(player.position.y < 610, "Player fell through terrain")
	var start_y: float = game.players[0].position.y
	var jump_event := InputEventKey.new()
	jump_event.physical_keycode = KEY_W
	jump_event.pressed = true
	Input.parse_input_event(jump_event)
	for i in 8:
		await physics_frame
	check(game.players[0].position.y < start_y - 20, "Jump did not lift player")
	jump_event.pressed = false
	Input.parse_input_event(jump_event)
	for i in 60:
		await physics_frame
	game.players[0].position = Vector2(1560, 580)
	await process_frame
	await process_frame
	check(game.saved_checkpoint, "Checkpoint did not activate")
	game.players[0].position = Vector2(1600, 1000)
	await physics_frame
	await physics_frame
	check(game.players[0].position.y < 700, "Fall did not respawn")
	game.show_menu()
	await process_frame
	await process_frame
	game.start_game(1)
	await process_frame
	await process_frame
	check(game.players.size() == 1, "Solo restart did not reset players")
	game.players[0].position = Vector2(390, 450)
	await process_frame
	await process_frame
	check(game.score == 1, "Collectible did not update score")
	game.touch_event("right", true)
	check(game.players[0].touch_axis == 1.0, "Touch direction failed")
	game.touch_event("right", false)
	check(game.players[0].touch_axis == 0.0, "Touch direction stuck")
	game.players[0].position = Vector2(game.level.exit[0] - 5, 580)
	await process_frame
	await process_frame
	check(game.completed, "Exit did not complete sandbox")
	print("PASS: localization, solo/co-op, terrain, checkpoint, respawn, fruit, touch, exit")
	quit(0)
