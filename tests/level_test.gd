extends SceneTree
## Level 01 can be finished: a reachability search over world/levels/01.json
## using the player's exported jump/run values (walking, jumping, dropping,
## vines) connects the spawn to the exit and every collectible. Then the real
## game is driven to the exit (win screen), to a fall (life lost) and to
## game over -> restart.
const Player = preload("res://scripts/player.gd")
var failures := 0
var level: Dictionary
var params: CharacterBody2D

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

## Walkable top surfaces, split where another block stands on them.
func surfaces() -> Array:
	var rects: Array[Rect2] = []
	for box in level.platforms: rects.append(Rect2(box[0], box[1], box[2], box[3]))
	var out := []
	for rect in rects:
		var pieces := [[rect.position.x, rect.end.x]]
		for other in rects:
			if other == rect: continue
			if other.position.y < rect.position.y - 1 and other.end.y >= rect.position.y - 1:
				var next := []
				for p in pieces:
					if other.end.x <= p[0] or other.position.x >= p[1]: next.append(p)
					else:
						if other.position.x > p[0]: next.append([p[0], other.position.x])
						if other.end.x < p[1]: next.append([other.end.x, p[1]])
				pieces = next
		for p in pieces:
			if p[1] - p[0] >= 24: out.append({"x0": p[0], "x1": p[1], "y": rect.position.y})
	return out

## Horizontal distance a jump with launch speed v covers when landing dy higher.
func jump_reach(v: float, horizontal: float, dy_up: float) -> float:
	var g: float = params.gravity
	var apex := v * v / (2.0 * g)
	if dy_up > apex * 0.92: return -1.0
	var t_up := v / g
	var t_down := sqrt(2.0 * (apex - dy_up) / (g * params.fall_gravity_scale))
	return horizontal * (t_up + t_down) * 0.8

func gap(a: Dictionary, b: Dictionary) -> float:
	return maxf(0.0, maxf(b.x0 - a.x1, a.x0 - b.x1))

func linked(a: Dictionary, b: Dictionary, v: float, speed: float) -> bool:
	var dy_up: float = a.y - b.y
	var reach := jump_reach(v, speed, dy_up)
	return reach >= 0.0 and gap(a, b) <= reach

func run() -> void:
	level = JSON.parse_string(FileAccess.get_file_as_string("res://world/levels/01.json"))
	params = Player.new()
	var nodes := surfaces()
	# Vines act as extra nodes at their top (climb up, jump off sideways).
	for vine in level.vines:
		nodes.append({"x0": vine[0] - 30, "x1": vine[0] + 30, "y": vine[1], "vine": vine})
	var start := -1
	var goal := -1
	for i in nodes.size():
		var n: Dictionary = nodes[i]
		if n.has("vine"): continue
		if level.spawns[0][0] >= n.x0 and level.spawns[0][0] <= n.x1 and absf(n.y - level.spawns[0][1]) < 30: start = i
		if level.exit[0] >= n.x0 and level.exit[0] <= n.x1 and absf(n.y - level.exit[1]) < 30: goal = i
	check(start >= 0 and goal >= 0, "spawn and exit stand on level surfaces")
	var seen := {start: true}
	var queue := [start]
	while not queue.is_empty():
		var i: int = queue.pop_front()
		var a: Dictionary = nodes[i]
		for j in nodes.size():
			if seen.has(j): continue
			var b: Dictionary = nodes[j]
			var ok := false
			if b.has("vine"):
				# Grab a vine from a surface its bottom reaches.
				ok = gap(a, b) <= 40.0 and a.y >= b.vine[1] and a.y <= b.vine[2] + 12
			elif a.has("vine"):
				ok = linked(a, b, params.jump_velocity * 0.6, params.walk_speed) or (b.y > a.y and gap(a, b) <= 160.0)
			else:
				ok = linked(a, b, params.jump_velocity, params.run_speed)
			if ok:
				seen[j] = true
				queue.append(j)
	check(seen.has(goal), "exit is reachable from the spawn (%d of %d surfaces reachable)" % [seen.size(), nodes.size()])
	# Every collectible hangs within jump height above a reachable surface.
	var apex: float = params.jump_velocity * params.jump_velocity / (2.0 * params.gravity)
	var spots := []
	for f in level.fruit: spots.append(Vector2(f[0], f[1]))
	for p in level.pickups: spots.append(Vector2(p[0], p[1]))
	spots.append(Vector2(level.boomerang_pickup[0], level.boomerang_pickup[1]))
	var unreachable := []
	for spot in spots:
		var ok := false
		for i in seen:
			var n: Dictionary = nodes[i]
			var top: float = n.y if not n.has("vine") else n.vine[1]
			var bottom: float = n.y if not n.has("vine") else n.vine[2]
			if spot.x >= n.x0 - 60 and spot.x <= n.x1 + 60 and spot.y <= bottom + 10 and spot.y >= top - apex - 70: ok = true
		if not ok: unreachable.append(spot)
	check(unreachable.is_empty(), "all %d collectibles are reachable %s" % [spots.size(), str(unreachable)])
	var secret: Array = level.secret
	check(Rect2(secret[0], secret[1], secret[2], secret[3]).has_point(Vector2(730, 225)), "secret area exists")
	params.free()
	# Real game: fall into water -> life lost and respawn; finish -> win screen.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(1, [0])
	await frames(30)
	var hero = game.players[0]
	hero.position = Vector2(1190, 500)
	hero.velocity = Vector2.ZERO
	await frames(40)
	check(game.lives == game.START_LIVES - 1 and hero.position.y < 700, "falling into the water costs a life and respawns")
	hero.position = Vector2(level.exit[0] - 5, 580)
	await frames(3)
	check(game.completed and game.overlay.find_child("ResultCard", true, false) != null, "reaching the exit completes the level and shows the win screen")
	var again: Button = game.overlay.find_child("Again", true, false)
	again.pressed.emit()
	await frames(5)
	check(not game.completed and game.lives == game.START_LIVES and game.score == 0, "play again restarts the level")
	# Death with the last life -> game over -> restart.
	game.lives = 1
	hero = game.players[0]
	hero.grace = 0
	hero.health = 1
	hero.hurt(hero.position.x + 40)
	check(hero.dead, "losing all health kills the hero")
	for i in 150:
		await physics_frame
		if game.game_over: break
	await process_frame
	check(game.game_over and game.overlay.find_child("ResultCard", true, false) != null, "last life lost shows the game over screen")
	game.overlay.find_child("Again", true, false).pressed.emit()
	await frames(5)
	check(not game.game_over and not game.players[0].dead and game.lives == game.START_LIVES, "restart after game over")
	if failures == 0: print("PASS: exit and all collectibles reachable with the player's physics, win screen, life loss, game over and restart")
	quit(1 if failures > 0 else 0)
