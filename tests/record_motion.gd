extends SceneTree
## Input-driven first-encounter motion study. Starts at the clearing, no camera teleports.
var game: Node2D
var elapsed := 0.0
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
	game.players[0].position = Vector2(1300, 600)
	game.players[0].checkpoint = Vector2(1300, 600)

func key(code: int, pressed: bool) -> void:
	if held.get(code, false) == pressed: return
	held[code] = pressed
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _physics_process(delta: float) -> bool:
	if not is_instance_valid(game) or not game.active: return false
	elapsed += delta
	var right := elapsed < 1.7 or (elapsed >= 4.5 and elapsed < 6.5)
	var left := (elapsed >= 2.5 and elapsed < 3.8) or (elapsed >= 6.5 and elapsed < 7.7)
	key(KEY_D, right)
	key(KEY_A, left)
	key(KEY_W, elapsed >= 5.7 and elapsed < 6.1)
	var hero = game.players[0]
	var dino = game.targets[0]
	var distance: float = dino.position.x - hero.position.x
	var in_reach: bool = distance * hero.facing > 0 and absf(distance) < dino.hit_radius + 100
	key(KEY_F, in_reach and int(elapsed * 60) % 28 < 5)
	return false
