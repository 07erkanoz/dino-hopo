extends SceneTree
const Roster = preload("res://scripts/roster.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func frames(count: int = 2) -> void:
	for i in count: await physics_frame

func check(condition: bool, message: String = "World check failed") -> void:
	if not condition:
		push_error(message)
		failures += 1

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames()
	check(Roster.hero_name(0) == "Çağan" and Roster.hero_name(2, "en") == "Deniz")
	game.show_character_select(2)
	await frames()
	var selection = game.overlay.get_child(game.overlay.get_child_count() - 1)
	check(selection.cards.size() == 4)
	selection.cards[3].pressed.emit()
	selection.cards[0].pressed.emit()
	selection.start_button.pressed.emit()
	await frames(90)
	check(game.players[0].hero_index == 3 and game.players[1].hero_index == 0)
	check(game.players[0].slot == 0 and game.players[1].slot == 1)
	check(game.forest.depth_layers.size() == 3)
	check(game.level.width > 4000 and game.level.regions.size() == 5)
	var hero = game.players[0]
	check(not hero.has_boomerang and not game.try_throw(hero))
	# Collect a real pickup; do not grant an invisible default power.
	hero.position = game.power_pickups[0] + Vector2(0, 40)
	await frames()
	await process_frame
	await process_frame
	check(hero.has_boomerang and game.power_pickups.size() == 1)
	# Safe open air: returns, stays owned, and a second throw is permitted.
	hero.position = Vector2(150, 600)
	hero.velocity = Vector2.ZERO
	hero.facing = -1
	check(game.try_throw(hero))
	check(not game.try_throw(hero), "Cannot have two projectiles for the same hero")
	await frames(120)
	check(hero.has_boomerang and not hero.boomerang_active, "Safe return should preserve ownership")
	check(game.try_throw(hero))
	await frames(120)
	check(hero.has_boomerang and not hero.boomerang_active)
	# A wall on the outbound path traps and removes it.
	game.make_platform(Rect2(50, 490, 25, 100))
	check(game.try_throw(hero))
	await frames(30)
	check(not hero.has_boomerang and not hero.boomerang_active, "Terrain collision must lose boomerang")
	# Melee is repeatable without needing any pickup.
	var target = game.targets[0]
	hero.position = Vector2(1540, 600)
	hero.facing = 1
	target.position = Vector2(1660, 600)
	hero.begin_swing()
	await frames(12)
	check(target.stunned > 0, "Club failed to stun nearby dinosaur")
	# A held jump touch near a vine climbs instead of repeatedly jumping.
	hero.position = Vector2(590, 536)
	hero.velocity = Vector2.ZERO
	hero.touch_jump = true
	await frames(20)
	check(hero.climbing and hero.position.y < 500, "Vine did not lift hero")
	hero.touch_jump = false
	# Discover upper path and exercise moving camera.
	hero.position = Vector2(730, 225)
	await frames()
	check(game.secret_found)
	for player in game.players: player.position.x = 2650
	await frames()
	check(game.camera.position.x > 2000)
	var zone: Node2D
	for child in game.world.get_children():
		if child.get_script() == load("res://scripts/rock_zone.gd") and child.position.x == 2300:
			zone = child
	check(zone.get_script() == load("res://scripts/rock_zone.gd"))
	zone.cycle = 0.95
	await frames(12)
	check(zone.falling, "Rock warning did not lead to a real falling rock")
	if failures == 0: print("PASS: four hero selection, exact names, world regions, limited discovery, safe returns/reuse, terrain loss, melee, climbing, secret, scrolling camera, falling rocks")
	quit(1 if failures > 0 else 0)
