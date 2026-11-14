extends SceneTree
## Writes the project's InputMap into project.godot (run once after changes):
## godot --headless --path . --script tools/setup_input.gd
## Solo actions accept every keyboard layout option and any gamepad; p1_/p2_
## actions split keyboard halves and gamepads 0/1 for shared-screen co-op.

func key(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.device = -1
	return e

func button(index: int, device := -1) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = index
	e.device = device
	return e

func axis(index: int, value: float, device := -1) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = index
	e.axis_value = value
	e.device = device
	return e

func action(name: String, events: Array, deadzone := 0.25) -> void:
	ProjectSettings.set_setting("input/" + name, {"deadzone": deadzone, "events": events})

func pad(device: int) -> Dictionary:
	return {
		"move_left": [button(JOY_BUTTON_DPAD_LEFT, device), axis(JOY_AXIS_LEFT_X, -1.0, device)],
		"move_right": [button(JOY_BUTTON_DPAD_RIGHT, device), axis(JOY_AXIS_LEFT_X, 1.0, device)],
		"move_up": [button(JOY_BUTTON_DPAD_UP, device), axis(JOY_AXIS_LEFT_Y, -1.0, device)],
		"move_down": [button(JOY_BUTTON_DPAD_DOWN, device), axis(JOY_AXIS_LEFT_Y, 1.0, device)],
		"jump": [button(JOY_BUTTON_A, device)],
		"attack": [button(JOY_BUTTON_X, device), button(JOY_BUTTON_B, device)],
		"throw": [button(JOY_BUTTON_Y, device), button(JOY_BUTTON_RIGHT_SHOULDER, device)],
	}

func _initialize() -> void:
	var solo_keys := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE, KEY_W, KEY_UP, KEY_Z], "attack": [KEY_F, KEY_J, KEY_X, KEY_CTRL],
		"throw": [KEY_G, KEY_K, KEY_C],
	}
	var p1_keys := {"move_left": [KEY_A], "move_right": [KEY_D], "move_up": [KEY_W], "move_down": [KEY_S],
		"jump": [KEY_W, KEY_SPACE], "attack": [KEY_F], "throw": [KEY_G]}
	var p2_keys := {"move_left": [KEY_LEFT], "move_right": [KEY_RIGHT], "move_up": [KEY_UP], "move_down": [KEY_DOWN],
		"jump": [KEY_UP, KEY_SHIFT], "attack": [KEY_K], "throw": [KEY_L]}
	for set in [["", solo_keys, -1], ["p1_", p1_keys, 0], ["p2_", p2_keys, 1]]:
		var pads := pad(set[2])
		for name in set[1]:
			var events: Array = []
			for code in set[1][name]: events.append(key(code))
			events.append_array(pads[name])
			action(set[0] + name, events)
	action("pause", [key(KEY_ESCAPE), key(KEY_P), button(JOY_BUTTON_START)])
	action("restart", [key(KEY_R), button(JOY_BUTTON_BACK)])
	ProjectSettings.save()
	print("InputMap written")
	quit()
