extends SceneTree
## A deterministic input-driven capture of the actual game; no teleporting camera.
var game: Node2D
var step := 0
var held_jump := 0.0
var held: Dictionary = {}

func _initialize() -> void:
	call_deferred("begin")

func begin() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(1, [0])

func key(code: int, pressed: bool) -> void:
	if held.get(code, false) == pressed: return
	held[code] = pressed
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _physics_process(delta: float) -> bool:
	if not is_instance_valid(game) or not game.active: return false
	var hero = game.players[0]
	key(KEY_D, true)
	held_jump = maxf(0, held_jump - delta)
	if hero.is_on_floor() and held_jump <= 0:
		var space = hero.get_world_2d().direct_space_state
		var front := PhysicsRayQueryParameters2D.create(hero.position + Vector2(0,-8), hero.position + Vector2(80,-8), 1)
		var ledge := PhysicsRayQueryParameters2D.create(hero.position + Vector2(70,-4), hero.position + Vector2(70,24), 1)
		if not space.intersect_ray(front).is_empty() or space.intersect_ray(ledge).is_empty():
			held_jump = 0.52
	key(KEY_W, held_jump > 0)
	var close_target := false
	for target in game.targets:
		if target.position.distance_to(hero.position) < 150: close_target = true
	key(KEY_F, close_target and step % 30 < 4)
	step += 1
	return false

func _finalize() -> void:
	if is_instance_valid(game) and not game.players.is_empty():
		print("DEMO end x=", game.players[0].position.x, " camera=", game.camera.position.x)
