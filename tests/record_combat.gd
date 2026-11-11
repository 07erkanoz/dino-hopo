extends SceneTree
## Starts at the actual encounter; all strikes/movement afterward use normal inputs.
var game: Node2D
var elapsed := 0.0
var held: Dictionary = {}

func _initialize() -> void:
	call_deferred("begin")

func begin() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(1,[0])
	game.players[0].position = Vector2(1540,600)
	game.players[0].checkpoint = Vector2(1540,600)

func key(code: int, pressed: bool) -> void:
	if held.get(code,false) == pressed: return
	held[code] = pressed
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _physics_process(delta: float) -> bool:
	if not is_instance_valid(game) or not game.active: return false
	elapsed += delta
	key(KEY_F, (elapsed >= .15 and elapsed < .25) or (elapsed >= 1.25 and elapsed < 1.35) or (elapsed >= 2.85 and elapsed < 2.95))
	key(KEY_D, (elapsed >= .95 and elapsed < 1.22) or (elapsed >= 3.6 and elapsed < 3.72))
	key(KEY_A, elapsed >= 2.4 and elapsed < 2.8)
	return false
