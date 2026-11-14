extends SceneTree
## Collecting food and bonuses (art/v2/pickups) raises the score and the HUD.
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("  ok: ", message)

func frames(n: int) -> void:
	for i in n: await physics_frame
	await process_frame
	await process_frame

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(1, [0])
	await frames(30)
	var hero = game.players[0]
	check(game.score == 0 and game.fruit_collected == 0, "score starts at zero")
	var kinds := {}
	for item in game.items: kinds[item.kind] = true
	for kind in ["meat", "egg", "heart", "star", "tablet"]:
		check(kinds.has(kind), "level places a '%s' pickup" % kind)
	# Fruit: +100 and the HUD counter follows.
	var fruit: Vector2 = game.berries[0]
	var fruit_count: int = game.berries.size()
	hero.position = fruit + Vector2(0, 40)
	await frames(2)
	check(game.score == game.POINTS.fruit and game.fruit_collected == 1 and game.berries.size() == fruit_count - 1, "fruit adds %d points" % game.POINTS.fruit)
	check(game.hud.score_label.text == "%06d" % game.score and game.hud.fruit_label.text == "×1", "HUD shows score and fruit count")
	# Each bonus type adds its own value; a heart also restores health.
	hero.health = 1
	# Isolate each bonus: no neighbouring fruit or secret-area reward.
	game.berries.clear()
	game.secret_found = true
	for kind in ["meat", "egg", "heart", "star", "tablet"]:
		var item
		for candidate in game.items:
			if candidate.kind == kind:
				item = candidate
				break
		var before: int = game.score
		hero.position = item.pos + Vector2(0, 50)
		hero.velocity = Vector2.ZERO
		await frames(2)
		check(game.score == before + game.POINTS[kind], "%s adds %d points" % [kind, game.POINTS[kind]])
		check(not game.items.has(item), "%s disappears once collected" % kind)
	check(hero.health == 2, "heart restores one health")
	# The same pickup cannot be scored twice.
	var settled: int = game.score
	await frames(5)
	check(game.score == settled, "no double counting")
	if failures == 0: print("PASS: fruit and five bonus pickups raise the score, HUD updates, heart heals")
	quit(1 if failures > 0 else 0)
