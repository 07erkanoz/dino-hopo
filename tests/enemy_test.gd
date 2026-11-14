extends SceneTree
## Enemies take damage and die: club hits drain the ceratopsian's health
## (hurt animation each time), the last hit plays "die", awards points and
## removes contact damage; the pterosaur dies after two hits.
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

## Real swing with the hero standing in front of the enemy.
func swing_at(game: Node2D, hero: CharacterBody2D, target: CharacterBody2D) -> void:
	await frames(50)
	hero.position = target.position + Vector2(-150, 0) if target.species == 0 else target.position + Vector2(-90, 60)
	hero.velocity = Vector2.ZERO
	hero.facing = 1
	hero.grace = 5.0
	target.velocity = Vector2.ZERO
	if target.species == 0:
		target.state = "recover"
		target.state_left = 10
	hero.begin_swing()
	await frames(36)

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(1, [0])
	await frames(60)
	var hero = game.players[0]
	var dino = game.targets[0]
	check(dino.species == 0 and game.targets.any(func(t): return t.species == 1), "level has two enemy species")
	var start_health: int = dino.health
	var score_before: int = game.score
	var saw_hurt := false
	for i in start_health:
		var before: int = dino.health
		await swing_at(game, hero, dino)
		check(dino.health == before - 1, "club hit %d lowers ceratopsian health to %d" % [i + 1, dino.health])
		if i < start_health - 1:
			saw_hurt = saw_hurt or dino.rig.current_state() == "hurt" or dino.recoil_left > 0
		await frames(10)
	check(saw_hurt, "non-lethal hits play the hurt reaction")
	check(not dino.alive and dino.state == "dead", "ceratopsian dies at 0 health")
	var died_anim := false
	for i in 20:
		await physics_frame
		if dino.rig.current_state() == "die": died_anim = true
	check(died_anim, "death animation plays")
	check(game.defeated == 1 and game.score >= score_before + dino.points, "defeat awards %d points" % dino.points)
	check(not dino.dangerous, "dead enemy is harmless")
	var hits_before: int = game.hit_events
	await swing_at(game, hero, dino)
	check(game.hit_events == hits_before, "dead enemy is no longer a target")
	await frames(140)
	check(not dino.visible, "body fades out after the death animation")
	# Pterosaur (flying) also dies.
	var ptero
	for target in game.targets:
		if target.species == 1:
			ptero = target
			break
	var ptero_hits := 0
	while ptero.alive and ptero_hits < 4:
		ptero.position = Vector2(1500, 470)
		ptero.state = "fly"
		await swing_at(game, hero, ptero)
		ptero_hits += 1
	check(not ptero.alive and ptero_hits == 2, "pterosaur dies after %d hits" % ptero_hits)
	if failures == 0: print("PASS: enemies take club damage, react, die with animation, award points and stop hurting")
	quit(1 if failures > 0 else 0)
