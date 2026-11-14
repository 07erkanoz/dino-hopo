extends SceneTree
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, detail: String) -> void:
	if not ok:
		push_error(detail)
		failures += 1

func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(1, [0])
	for i in 90: await physics_frame
	var hero = game.players[0]
	var run_frames: Dictionary = {}
	key(KEY_D, true)
	for i in 42:
		await physics_frame
		run_frames[hero.run_frame] = true
	check(run_frames.size() >= 7, "Run cycle did not use its distinct steps")
	check(hero.velocity.x > 290, "Acceleration did not reach running speed")
	key(KEY_D, false)
	for i in 30: await physics_frame
	var stopped_distance: float = hero.run_distance
	for i in 20: await physics_frame
	check(is_equal_approx(hero.run_distance, stopped_distance), "Feet kept cycling while stopped")
	check(hero.motion_state == "idle", "Stopped hero did not return to idle")
	var jump_states: Dictionary = {}
	key(KEY_W, true)
	for i in 80:
		await physics_frame
		jump_states[hero.motion_state] = true
	key(KEY_W, false)
	check(jump_states.has("jump") and jump_states.has("fall") and jump_states.has("land"), "Jump omitted rise, fall or landing state")
	var dinosaur = game.targets[0]
	check(dinosaur.body_height > 128 * 1.5, "Large dinosaur is still smaller than the hero")
	hero.position = Vector2(1000, 600)
	var walk_frames: Dictionary = {}
	for i in 120:
		await physics_frame
		walk_frames[dinosaur.walk_frame] = true
	check(walk_frames.size() >= 7, "Dinosaur gait did not use distinct leg phases")
	dinosaur.stun()
	for i in 15: await physics_frame
	var stopped_step: int = dinosaur.walk_frame
	for i in 20: await physics_frame
	check(dinosaur.walk_frame == stopped_step, "Stunned dinosaur legs kept sliding")
	# A telegraphed encounter must include a warning and recovery, not constant contact kills.
	dinosaur.stunned = 0
	dinosaur.state = "patrol"
	dinosaur.position = Vector2(1700, 600)
	hero.position = Vector2(1450, 600)
	hero.velocity = Vector2.ZERO
	hero.grace = 0
	var states: Dictionary = {}
	for i in 180:
		await physics_frame
		states[dinosaur.state] = true
	check(states.has("windup") and states.has("charge") and states.has("recover"), "Encounter omitted warning, charge or recovery")
	hero.grace = 0
	var old_health: int = hero.health
	hero.hurt(hero.position.x + 100)
	check(hero.health == old_health - 1 or hero.health == 3, "Damage/respawn did not update health")
	check(hero.grace > 0, "Damage has no recovery grace")
	if failures == 0: print("PASS: travel-linked8-step run/walk, stationary feet, acceleration, anticipation/air/landing, large species scale, telegraphed charge/recovery, damage grace")
	quit(1 if failures > 0 else 0)
