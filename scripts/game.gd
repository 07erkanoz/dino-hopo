extends Node2D

const Player = preload("res://scripts/player.gd")
const TEXT := {
	"tr": {"solo": "Tek oyuncu", "duo": "İki oyuncu · aynı ekran", "sub": "Hareket test alanı · geliştirme sürümü", "help": "P1: A/D + W     P2: ←/→ + ↑     R: geri dön     Esc: menü", "fruit": "Meyve", "check": "Kontrol noktası!", "finish": "Test alanı tamam!", "back": "Menüye dön", "hint": "Üst yoldaki meyveleri keşfet!"},
	"en": {"solo": "One player", "duo": "Two players · shared screen", "sub": "Movement sandbox · development build", "help": "P1: A/D + W     P2: ←/→ + ↑     R: respawn     Esc: menu", "fruit": "Fruit", "check": "Checkpoint!", "finish": "Sandbox complete!", "back": "Back to menu", "hint": "Explore the fruit on the upper path!"}
}
var language := "tr"
var world: Node2D
var overlay: CanvasLayer
var camera: Camera2D
var players: Array = []
var berries: Array[Vector2] = []
var platforms: Array[Rect2] = []
var score := 0
var total := 0
var active := false
var completed := false
var saved_checkpoint := false
var hud: Label
var toast: Label
var menu: Control
var left_held := false
var right_held := false

func _ready() -> void:
	overlay = CanvasLayer.new()
	add_child(overlay)
	show_menu()

func tr_text(key: String) -> String:
	return TEXT[language][key]

func clear_ui() -> void:
	for child in overlay.get_children():
		child.queue_free()

func label_at(text: String, where: Vector2, size: int, parent: Node) -> Label:
	var label := Label.new()
	label.text = text
	label.position = where
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("183f43"))
	parent.add_child(label)
	return label

func show_menu() -> void:
	active = false
	if is_instance_valid(world):
		world.queue_free()
	players.clear()
	platforms.clear()
	berries.clear()
	clear_ui()
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(menu)
	var backdrop := ColorRect.new()
	backdrop.color = Color("ffe9b8")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	var title := Label.new()
	title.text = "DINO HOP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 76)
	title.add_theme_color_override("font_color", Color("b65730"))
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = tr_text("sub")
	subtitle.add_theme_color_override("font_color", Color("183f43"))
	box.add_child(subtitle)
	for count in [1, 2]:
		var button := Button.new()
		button.text = tr_text("solo" if count == 1 else "duo")
		button.custom_minimum_size = Vector2(480, 64)
		button.pressed.connect(start_game.bind(count))
		box.add_child(button)
	var lang := Button.new()
	lang.text = "Türkçe / English"
	lang.custom_minimum_size.y = 54
	lang.pressed.connect(func():
		language = "en" if language == "tr" else "tr"
		show_menu())
	box.add_child(lang)
	queue_redraw()

func start_game(count: int) -> void:
	clear_ui()
	left_held = false
	right_held = false
	world = Node2D.new()
	add_child(world)
	players.clear()
	platforms.clear()
	berries.clear()
	score = 0
	completed = false
	saved_checkpoint = false
	for rect in [Rect2(0, 600, 1100, 400), Rect2(1260, 600, 1940, 400), Rect2(340, 460, 192, 40), Rect2(650, 340, 192, 40), Rect2(970, 410, 192, 40), Rect2(1450, 470, 192, 40), Rect2(1760, 345, 192, 40), Rect2(2060, 440, 192, 40), Rect2(2390, 330, 192, 40), Rect2(2670, 460, 192, 40)]:
		make_platform(rect)
	for spot in [Vector2(390, 415), Vector2(470, 415), Vector2(700, 295), Vector2(780, 295), Vector2(1030, 365), Vector2(1510, 425), Vector2(1820, 300), Vector2(2120, 395), Vector2(2450, 285), Vector2(2730, 415), Vector2(2870, 550)]:
		berries.append(spot)
	total = berries.size()
	for i in count:
		var player := Player.new()
		player.slot = i
		player.tint = Color("efa444") if i == 0 else Color("45bcb1")
		player.position = Vector2(150 + i * 90, 580)
		player.checkpoint = player.position
		player.collision_layer = 2
		player.collision_mask = 1
		world.add_child(player)
		players.append(player)
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	world.add_child(camera)
	hud = label_at("", Vector2(24, 16), 26, overlay)
	label_at(tr_text("help"), Vector2(24, 54), 18, overlay)
	toast = label_at(tr_text("hint"), Vector2(24, 82), 20, overlay)
	var menu_button := Button.new()
	menu_button.text = "≡"
	menu_button.position = Vector2(1190, 16)
	menu_button.custom_minimum_size = Vector2(64, 54)
	menu_button.pressed.connect(show_menu)
	overlay.add_child(menu_button)
	make_touch_controls()
	active = true
	queue_redraw()

func make_platform(rect: Rect2) -> void:
	platforms.append(rect)
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.position = rect.get_center()
	body.add_child(shape)
	world.add_child(body)

func make_touch_controls() -> void:
	var actions := ["left", "right", "jump"]
	for i in 3:
		var button := TouchScreenButton.new()
		var circle := CircleShape2D.new()
		circle.radius = 46.0
		button.shape = circle
		button.position = [Vector2(78, 640), Vector2(190, 640), Vector2(1190, 640)][i]
		button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
		var action: String = actions[i]
		button.pressed.connect(touch_event.bind(action, true))
		button.released.connect(touch_event.bind(action, false))
		overlay.add_child(button)
		var circle_visual := Polygon2D.new()
		var points := PackedVector2Array()
		for j in 32:
			points.append(Vector2.from_angle(j * TAU / 32.0) * 46.0)
		circle_visual.polygon = points
		circle_visual.color = Color(1, 0.96, 0.83, 0.65)
		button.add_child(circle_visual)
		var symbol := label_at(["←", "→", "↑"][i], Vector2(-24, -35), 48, button)
		symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE

func touch_event(action: String, pressed: bool) -> void:
	if players.is_empty():
		return
	if action == "left": left_held = pressed
	if action == "right": right_held = pressed
	if action == "jump": players[0].touch_jump = pressed
	players[0].touch_axis = float(right_held) - float(left_held)

func _process(_delta: float) -> void:
	if not active:
		return
	var center := Vector2.ZERO
	for player in players:
		center += player.position
	center /= players.size()
	camera.position = Vector2(clampf(center.x, 640, 2560), 360)
	for player in players:
		if player.position.x < camera.position.x - 620:
			player.position = Vector2(camera.position.x - 480, 220)
		if player.position.x > 1550 and not saved_checkpoint:
			saved_checkpoint = true
			for other in players:
				other.checkpoint = Vector2(1560 + other.slot * 70, 580)
			toast.text = tr_text("check")
		for i in range(berries.size() - 1, -1, -1):
			if player.position.distance_to(berries[i] + Vector2(0, 35)) < 55:
				berries.remove_at(i)
				score += 1
	if not completed:
		var all_at_exit := true
		for player in players:
			if player.position.x < 3030:
				all_at_exit = false
		if all_at_exit:
			completed = true
			toast.text = tr_text("finish")
	hud.text = "Dino Hop!  ·  %s %d / %d" % [tr_text("fruit"), score, total]
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		if event.physical_keycode == KEY_ESCAPE:
			show_menu()
		if event.physical_keycode == KEY_R and active:
			for player in players:
				player.respawn()

func _draw() -> void:
	if not active:
		return
	draw_rect(Rect2(-1000, -1000, 6000, 2400), Color("9cdbdd"))
	for i in range(-1, 10):
		var x := float(i * 430)
		draw_colored_polygon(PackedVector2Array([Vector2(x-200, 600), Vector2(x+150, 155), Vector2(x+500, 600)]), Color("79b6ba"))
		draw_circle(Vector2(x+90, 135), 38, Color("fff1cd"))
		draw_circle(Vector2(x+130, 125), 48, Color("fff1cd"))
		draw_circle(Vector2(x+170, 140), 32, Color("fff1cd"))
	# Water gap; falling into it returns to checkpoint.
	draw_rect(Rect2(1100, 650, 160, 350), Color("3a9fc6"))
	for rect in platforms:
		draw_rect(rect, Color("ae754e"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 16)), Color("85bc50"))
		for x in range(int(rect.position.x) + 16, int(rect.end.x), 64):
			draw_circle(Vector2(x, rect.position.y + 30), 5, Color("d69861"))
	for fruit in berries:
		draw_circle(fruit, 13, Color("e85d59"))
		draw_line(fruit + Vector2(0, -10), fruit + Vector2(7, -21), Color("3d854b"), 5)
	draw_line(Vector2(1560, 600), Vector2(1560, 500), Color("6c4935"), 8)
	draw_rect(Rect2(1560, 500, 60, 38), Color("f6d06e") if saved_checkpoint else Color("fff1cd"))
	draw_circle(Vector2(3100, 560), 70, Color("674e49"))
	draw_circle(Vector2(3100, 570), 48, Color("293f43"))
