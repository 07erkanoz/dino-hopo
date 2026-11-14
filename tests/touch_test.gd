extends SceneTree
## Touch buttons: hidden on a desktop without a touchscreen, shown on mobile
## (forced here), use the art/v2/ui icons and move/jump/attack the hero.
const TouchControls = preload("res://scripts/touch_controls.gd")
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

func run() -> void:
	var mobile := OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("mobile")
	check(not mobile and not DisplayServer.is_touchscreen_available(), "running on a desktop without touchscreen")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(1, [0])
	await frames(20)
	var touch: Control = game.touch
	check(touch != null and not TouchControls.should_show(), "desktop: should_show() is false")
	check(not touch.visible and not touch.is_visible_in_tree(), "desktop: touch buttons are hidden")
	for action in ["left", "right", "jump", "club"]:
		check(touch.buttons.has(action) and touch.buttons[action] is TouchScreenButton, "%s is a TouchScreenButton" % action)
	check(String(touch.buttons["jump"].texture_normal.resource_path).begins_with("res://art/v2/ui/touch-"), "buttons use art/v2/ui icons")
	# Mobile layout (forced, as on Android/iOS).
	TouchControls.force_visible = true
	game.start_game(1, [0])
	await frames(20)
	check(game.touch.visible, "mobile: touch buttons are visible")
	var hero = game.players[0]
	var start_x: float = hero.position.x
	game.touch.buttons["right"].pressed.emit()
	await frames(20)
	check(hero.position.x > start_x + 20, "touch right moves the hero")
	game.touch.buttons["right"].released.emit()
	await frames(10)
	game.touch.buttons["jump"].pressed.emit()
	await frames(6)
	check(not hero.is_on_floor() and hero.velocity.y < 0, "touch jump jumps")
	game.touch.buttons["jump"].released.emit()
	await frames(60)
	game.touch.buttons["club"].pressed.emit()
	await frames(3)
	check(hero.swing_left > 0, "touch club swings")
	game.touch.buttons["club"].released.emit()
	TouchControls.force_visible = false
	# A touch arriving on a desktop with a touchscreen reveals the buttons.
	game.start_game(1, [0])
	await frames(5)
	var event := InputEventScreenTouch.new()
	event.pressed = true
	event.position = Vector2(100, 600)
	Input.parse_input_event(event)
	await frames(3)
	check(game.touch.visible, "first screen touch reveals the buttons")
	if failures == 0: print("PASS: touch buttons hidden on desktop, visible on mobile, art/v2/ui icons, move/jump/club work")
	quit(1 if failures > 0 else 0)
