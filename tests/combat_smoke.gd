extends SceneTree
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func settle(count: int = 2) -> void:
	for i in count: await physics_frame
	await process_frame
	await process_frame

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await settle()
	game.start_game(1, [0])
	await settle(90)
	var hero = game.players[0]
	var target = game.targets[0]
	target.position = Vector2(1700,600)
	target.stunned = 0
	target.state = "recover"
	target.state_left = 10
	target.velocity = Vector2.ZERO
	hero.position = Vector2(1320,600)
	hero.velocity = Vector2.ZERO
	hero.facing = 1
	# A miss must have an attack animation/swish but no damage or contact effects.
	hero.begin_swing()
	var frames: Dictionary = {}
	for i in 50:
		await physics_frame
		frames[hero.attack_frame] = true
	check(frames.size() == 8, "Body attack did not play all8 phases")
	check(hero.swing_sound_played, "Swing has no whoosh event")
	check(game.hit_events == 0 and not hero.attack_connected, "A miss incorrectly created a hit")
	# A real contact must have one hit, visible recoil, impact pause and actual audio.
	hero.position = Vector2(1540,600)
	hero.velocity = Vector2.ZERO
	hero.facing = 1
	target.position = Vector2(1700,600)
	target.velocity = Vector2.ZERO
	target.state = "recover"
	target.state_left = 10
	var start_x: float = target.position.x
	var hit_count: int = target.stun_count
	var reactions: Dictionary = {}
	var saw_pause := false
	var saw_feedback := false
	var saw_sound := false
	hero.begin_swing()
	for i in 60:
		await physics_frame
		if target.recoil_left > 0: reactions[target.reaction_frame] = true
		if hero.hit_pause > 0 and target.hit_pause > 0: saw_pause = true
		for node in game.world.get_children():
			if node.get_script() == load("res://scripts/hit_feedback.gd"):
				saw_feedback = true
				for child in node.get_children():
					if child is AudioStreamPlayer and child.playing: saw_sound = true
	check(game.hit_events == 1 and target.stun_count == hit_count + 1, "One swing hit the same enemy more than once or missed")
	check(target.position.x > start_x + 15, "Enemy has no physical recoil")
	check(reactions.size() == 4, "Enemy omitted its4 body reaction phases")
	check(saw_pause and saw_feedback and saw_sound, "Impact pause, cloud or actual sound player missing")
	check(hero.attack_connected, "Attacker never registered contact")
	# Facing the wrong way cannot hit a target behind the player.
	var before: int = game.hit_events
	hero.position = Vector2(1540,600)
	hero.facing = -1
	hero.begin_swing()
	await settle(50)
	check(game.hit_events == before, "Attack hit a target behind the hero")
	# Real terrain between club and target blocks the strike.
	hero.position = Vector2(1540,600)
	hero.velocity = Vector2.ZERO
	hero.facing = 1
	target.position = Vector2(1700,600)
	target.velocity = Vector2.ZERO
	target.stunned = 0
	target.state = "recover"
	target.state_left = 10
	game.make_platform(Rect2(1588,450,20,150))
	await settle(2)
	hero.begin_swing()
	await settle(50)
	check(game.hit_events == before, "Melee passed through terrain")
	for name in ["swing", "wood_hit", "recoil_a", "recoil_b"]:
		var stream = load("res://audio/sfx/"+name+".wav")
		check(stream.get_length() > 0.1 and stream.data.size() > 1000, "Empty sound asset")
	if failures == 0: print("PASS:8-frame attack, miss/behind/wall rejection, one contact per swing,4 recoil phases, physical shove, local hit-stop, live audio and impact particles")
	quit(1 if failures > 0 else 0)
