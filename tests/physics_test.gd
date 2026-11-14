extends SceneTree
## Player movement physics: acceleration/deceleration, variable jump height,
## coyote time and jump buffer. Uses a bare test arena (no level, no enemies).
const Player = preload("res://scripts/player.gd")
var failures := 0
var arena: Node2D

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("  ok: ", message)

func block(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.position = rect.get_center()
	body.add_child(shape)
	arena.add_child(body)

func frames(n: int) -> void:
	for i in n: await physics_frame

func release_all() -> void:
	for action in ["move_left", "move_right", "jump", "attack"]: Input.action_release(action)

func fresh_player(at: Vector2) -> CharacterBody2D:
	var hero := Player.new()
	hero.hero_index = 0
	hero.sfx_enabled = false
	hero.position = at
	hero.checkpoint = at
	hero.collision_layer = 2
	hero.collision_mask = 1
	arena.add_child(hero)
	return hero

## Highest point (smallest y) reached during one jump.
func jump_apex(hero: CharacterBody2D, hold_frames: int) -> float:
	var start_y: float = hero.position.y
	var apex := start_y
	Input.action_press("jump")
	for i in 90:
		await physics_frame
		if i == hold_frames: Input.action_release("jump")
		apex = minf(apex, hero.position.y)
		if i > 5 and hero.is_on_floor(): break
	Input.action_release("jump")
	return start_y - apex

func run() -> void:
	arena = Node2D.new()
	root.add_child(arena)
	block(Rect2(-200, 600, 1400, 200))     # floor y=600, x -200..1200
	block(Rect2(1500, 600, 800, 200))      # far floor after a pit (1200..1500)
	var hero := fresh_player(Vector2(100, 600))
	await frames(30)
	check(hero.is_on_floor(), "hero rests on the floor")
	# Acceleration: speed builds over several frames, walk first, then run.
	Input.action_press("move_right")
	await frames(3)
	check(hero.velocity.x > 0.0 and hero.velocity.x < hero.walk_speed, "acceleration is gradual (%.0f px/s after 3 frames)" % hero.velocity.x)
	await frames(12)
	check(is_equal_approx(hero.velocity.x, hero.walk_speed), "walk speed reached before run delay")
	await frames(30)
	check(hero.velocity.x > hero.walk_speed + 50.0, "breaks into a run after run_after (%.0f px/s)" % hero.velocity.x)
	Input.action_release("move_right")
	await frames(2)
	check(hero.velocity.x > 0.0, "deceleration is not instant")
	await frames(20)
	check(absf(hero.velocity.x) < 1.0, "deceleration stops the hero")
	# Variable jump height: a tap gives a much lower jump than a held press.
	hero.position = Vector2(300, 600)
	hero.velocity = Vector2.ZERO
	await frames(10)
	var full := await jump_apex(hero, 80)
	await frames(10)
	var short := await jump_apex(hero, 2)
	check(full > 130.0, "held jump reaches %.0f px" % full)
	check(short < full * 0.5 and short > 10.0, "early release cuts the jump (%.0f vs %.0f px)" % [short, full])
	# Coyote time: jumping shortly after leaving a ledge still works...
	await frames(10)
	for case in [[3, true], [12, false]]:
		hero.position = Vector2(1160, 600)
		hero.velocity = Vector2.ZERO
		await frames(10)
		hero.velocity.x = 200.0
		Input.action_press("move_right")
		var left_ground := -1
		for i in 60:
			await physics_frame
			if not hero.is_on_floor() and hero.velocity.y >= 0.0:
				left_ground = i
				break
		await frames(int(case[0]) - 1)
		Input.action_release("move_right")
		var y_before: float = hero.velocity.y
		Input.action_press("jump")
		await frames(2)
		var jumped: bool = hero.velocity.y < -400.0
		Input.action_release("jump")
		var ms := int(case[0]) * 1000 / 60
		if case[1]: check(left_ground >= 0 and jumped, "coyote jump %d ms after leaving the ledge" % ms)
		else: check(not jumped, "no jump %d ms after leaving the ledge (coyote %.2f s)" % [ms, hero.coyote_time])
		await frames(40)
		hero.position = Vector2(300, 600)
		hero.velocity = Vector2.ZERO
		await frames(5)
	# Jump buffer: pressing just before landing jumps on touchdown; too early does not.
	for case in [[0.07, true], [0.25, false]]:
		hero.position = Vector2(300, 600)
		hero.velocity = Vector2.ZERO
		await frames(10)
		hero.position = Vector2(300, 600 - 220)
		hero.velocity = Vector2.ZERO
		var pressed := false
		var relaunched := false
		var landed := false
		for i in 120:
			await physics_frame
			if not pressed and hero.velocity.y > 0.0:
				# Estimate time to floor and press `case[0]` seconds before touchdown.
				var remaining: float = 600.0 - hero.position.y
				var v: float = hero.velocity.y
				var g: float = hero.gravity * hero.fall_gravity_scale
				var t := (-v + sqrt(v * v + 2.0 * g * remaining)) / g
				if t <= case[0]:
					Input.action_press("jump")
					pressed = true
			if hero.is_on_floor(): landed = true
			if landed and hero.velocity.y < -400.0:
				relaunched = true
				break
			if landed and i > 0 and hero.is_on_floor() and pressed and hero.velocity.y == 0.0:
				await frames(6)
				relaunched = hero.velocity.y < -400.0
				break
		Input.action_release("jump")
		if case[1]: check(relaunched, "buffered jump %.2f s before landing fires on touchdown" % case[0])
		else: check(not relaunched, "press %.2f s before landing is outside the %.2f s buffer" % [case[0], hero.jump_buffer_time])
		await frames(50)
	# Exported tuning values exist (inspector-editable).
	var exported := []
	for prop in hero.get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.usage & PROPERTY_USAGE_EDITOR: exported.append(prop.name)
	for name in ["walk_speed", "run_speed", "ground_accel", "ground_decel", "air_accel", "jump_velocity", "jump_cut", "coyote_time", "jump_buffer_time", "landing_snap", "corner_correction"]:
		check(name in exported, "@export " + name)
	release_all()
	if failures == 0: print("PASS: acceleration/deceleration, variable jump, coyote time, jump buffer, exported tuning")
	quit(1 if failures > 0 else 0)
