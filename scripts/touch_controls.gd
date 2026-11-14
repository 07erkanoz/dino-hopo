extends Control
## On-screen touch buttons (art/v2/ui): left/right bottom-left, club/jump
## bottom-right, plus a small boomerang button. Uses only TouchScreenButton and
## engine feature tags, so the same code runs on Android and (later) iOS.
## Hidden on desktops without a touchscreen; shown when a touch arrives.

const ICONS := {"left": "touch-left", "right": "touch-right", "club": "touch-attack", "jump": "touch-jump"}
const BUTTON_SIZE := 132.0

var game: Node2D
var buttons: Dictionary = {}
## Captures and tests can force the mobile layout on a desktop.
static var force_visible := false

static func should_show() -> bool:
	if force_visible: return true
	for feature in ["android", "ios", "mobile", "web_android", "web_ios"]:
		if OS.has_feature(feature): return true
	return DisplayServer.is_touchscreen_available()

func _init() -> void:
	name = "TouchControls"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	visible = should_show()
	var left_group := corner(Control.PRESET_BOTTOM_LEFT)
	var right_group := corner(Control.PRESET_BOTTOM_RIGHT)
	add_button(left_group, "left", Vector2(30, -BUTTON_SIZE - 24))
	add_button(left_group, "right", Vector2(30 + BUTTON_SIZE + 22, -BUTTON_SIZE - 24))
	add_button(right_group, "club", Vector2(-2 * BUTTON_SIZE - 52, -BUTTON_SIZE - 24))
	add_button(right_group, "jump", Vector2(-BUTTON_SIZE - 30, -BUTTON_SIZE - 24))
	add_button(right_group, "throw", Vector2(-2 * BUTTON_SIZE - 20, -2 * BUTTON_SIZE - 40), 76.0)

func corner(preset: int) -> Control:
	var group := Control.new()
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(group)
	group.set_anchors_and_offsets_preset(preset)
	group.size = Vector2.ZERO
	return group

func add_button(parent: Control, action: String, where: Vector2, size := BUTTON_SIZE) -> void:
	var button := TouchScreenButton.new()
	button.name = "Touch_" + action
	if ICONS.has(action):
		var texture: Texture2D = load("res://art/v2/ui/%s.png" % ICONS[action])
		button.texture_normal = texture
		button.scale = Vector2.ONE * (size / texture.get_width())
		var circle := CircleShape2D.new()
		circle.radius = texture.get_width() * 0.5
		button.shape = circle
		button.shape_centered = true
	else:
		# Boomerang: no dedicated v2 icon yet -> glass disc + boomerang sprite.
		var circle := CircleShape2D.new()
		circle.radius = size * 0.5
		button.shape = circle
		var disc := Polygon2D.new()
		var points := PackedVector2Array()
		for i in 32: points.append(Vector2.from_angle(i * TAU / 32.0) * size * 0.5)
		disc.polygon = points
		disc.color = Color(1, 0.97, 0.88, 0.45)
		button.add_child(disc)
		var boomerang := Sprite2D.new()
		boomerang.texture = preload("res://scripts/art.gd").sprite("equipment", 1)
		boomerang.scale = Vector2.ONE * (size * 0.6 / boomerang.texture.get_width())
		button.add_child(boomerang)
		where += Vector2(size * 0.5, size * 0.5)
	button.position = where
	button.passby_press = action in ["left", "right"]
	button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
	button.pressed.connect(_on_touch.bind(action, true))
	button.released.connect(_on_touch.bind(action, false))
	parent.add_child(button)
	buttons[action] = button

func _on_touch(action: String, pressed: bool) -> void:
	if is_instance_valid(game): game.touch_event(action, pressed)
	modulate_button(action, pressed)

func modulate_button(action: String, pressed: bool) -> void:
	if buttons.has(action):
		buttons[action].self_modulate = Color(0.8, 0.95, 1.0, 1.0) if pressed else Color.WHITE

func _process(_delta: float) -> void:
	if is_instance_valid(game) and not game.players.is_empty():
		buttons["throw"].visible = game.players[0].has_boomerang
