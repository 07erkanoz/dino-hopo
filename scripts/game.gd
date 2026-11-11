extends Node2D

const Player = preload("res://scripts/player.gd")
const Art = preload("res://scripts/art.gd")
const BACKGROUND = preload("res://art/backgrounds/waterfall-valley.png")
const TEXT := {
	"tr": {"solo": "Tek oyuncu", "duo": "İki oyuncu · aynı ekran", "sub": "Şelale Vadisi · çizim ve hareket denemesi", "help": "P1: A/D + W     P2: ←/→ + ↑     R: geri dön     Esc: menü", "fruit": "Meyve", "check": "Kontrol noktası!", "finish": "Test alanı tamam!", "back": "Menüye dön", "hint": "Üst yoldaki meyveleri keşfet!"},
	"en": {"solo": "One player", "duo": "Two players · shared screen", "sub": "Waterfall Valley · art and movement preview", "help": "P1: A/D + W     P2: ←/→ + ↑     R: respawn     Esc: menu", "fruit": "Fruit", "check": "Checkpoint!", "finish": "Sandbox complete!", "back": "Back to menu", "hint": "Explore the fruit on the upper path!"}
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
var soil_texture: AtlasTexture

func _ready() -> void:
	soil_texture = AtlasTexture.new()
	soil_texture.atlas = Art.sprite("props", 2).atlas
	soil_texture.region = Rect2(1155, 156, 248, 245)
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
	var painting := TextureRect.new()
	painting.texture = BACKGROUND
	painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	painting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(painting)
	var veil := ColorRect.new()
	veil.color = Color(1.0, 0.95, 0.82, 0.62)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(veil)
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
	var gallery := Button.new()
	gallery.text = "Çizim galerisi" if language == "tr" else "Art gallery"
	gallery.custom_minimum_size.y = 54
	gallery.pressed.connect(show_gallery)
	box.add_child(gallery)
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
	# Readability panels behind HUD, keep their draw order behind text.
	for bounds in [Rect2(12, 10, 680, 43), Rect2(12, 55, 790, 55)]:
		var panel := Panel.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(1.0, 0.96, 0.85, 0.88)
		style.set_corner_radius_all(12)
		panel.add_theme_stylebox_override("panel", style)
		panel.position = bounds.position
		panel.size = bounds.size
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.add_child(panel)
		overlay.move_child(panel, 0)
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

func draw_asset(group: String, index: int, foot: Vector2, height: float) -> void:
	var texture := Art.sprite(group, index)
	var dimensions := texture.get_size()
	var size := dimensions * (height / dimensions.y)
	draw_texture_rect(texture, Rect2(foot - Vector2(size.x / 2.0, size.y), size), false)

func _draw() -> void:
	if not active:
		return
	# Full 16:9 painting stays behind the camera, avoiding repeated image seams.
	draw_texture_rect(BACKGROUND, Rect2(camera.position - Vector2(640, 360), Vector2(1280, 720)), false)
	# Background cast; these are artwork previews, not enemy AI or ride mechanics.
	draw_asset("creatures", 1, Vector2(700, 605), 158)
	draw_asset("creatures", 2, Vector2(2200, 605), 105)
	draw_asset("creatures", 4, Vector2(1190, 712), 75)
	var flight_y := 205.0 + sin(Time.get_ticks_msec() / 1100.0) * 12.0
	draw_asset("creatures", 3, Vector2(1870, flight_y), 110)
	for rect in platforms:
		if rect.size.y > 100:
			# An interior region, excluding outlined tile edges, fills the soil.
			for x in range(int(rect.position.x), int(rect.end.x), 128):
				var tile_width := minf(128, rect.end.x - x)
				for y in range(int(rect.position.y) + 35, int(rect.end.y), 126):
					draw_texture_rect(soil_texture, Rect2(x, y, tile_width, 128), false)
			# Reuse the painted top as matching segments, not tiny stretched rocks.
			for x in range(int(rect.position.x), int(rect.end.x), 192):
				var width := minf(192, rect.end.x - x)
				draw_texture_rect(Art.sprite("props", 0), Rect2(x - 1, rect.position.y - 12, width + 2, 86), false)
		else:
			draw_texture_rect(Art.sprite("props", 0), Rect2(rect.position - Vector2(4, 12), Vector2(rect.size.x + 8, 88)), false)
	for fruit in berries:
		draw_asset("props", 3, fruit + Vector2(0, 15), 34)
	draw_asset("props", 4, Vector2(1560, 600), 112)
	if saved_checkpoint:
		draw_circle(Vector2(1560, 482), 7, Color("ffdb6b"))
	draw_asset("props", 5, Vector2(3090, 605), 156)
	draw_asset("creatures", 0, Vector2(875, 600), 92)
	draw_asset("creatures", 5, Vector2(2590, 600), 84)

func show_gallery() -> void:
	active = false
	clear_ui()
	var base := Control.new()
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(base)
	var paper := ColorRect.new()
	paper.color = Color("f6edda")
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.add_child(paper)
	var gallery_theme := Theme.new()
	var gallery_panel := StyleBoxFlat.new()
	gallery_panel.bg_color = Color("fcf7ed")
	gallery_panel.border_color = Color("dbc9a7")
	gallery_panel.set_border_width_all(2)
	gallery_panel.set_corner_radius_all(12)
	gallery_theme.set_stylebox("panel", "TabContainer", gallery_panel)
	base.theme = gallery_theme
	label_at("DINO HOP!  /  " + ("ÇİZİM GALERİSİ" if language == "tr" else "ART GALLERY"), Vector2(30, 18), 32, base)
	var tabs := TabContainer.new()
	tabs.position = Vector2(24, 80)
	tabs.size = Vector2(1232, 555)
	base.add_child(tabs)
	var items := [
		["Kahramanlar / Heroes", "res://art/characters/heroes-poses.png"],
		["Vadi / Valley", "res://art/backgrounds/waterfall-valley.png"],
		["Zemin / Props", "res://art/environment/jungle-props.png"],
		["Canlılar / Creatures", "res://art/creatures/creatures-natural-v3.png"]
	]
	for item in items:
		var image := TextureRect.new()
		image.name = item[0]
		image.texture = load(item[1])
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tabs.add_child(image)
	var back := Button.new()
	back.text = tr_text("back")
	back.position = Vector2(30, 651)
	back.custom_minimum_size = Vector2(220, 50)
	back.pressed.connect(show_menu)
	base.add_child(back)
	label_at("WIP · " + ("Poz çizimleri; tam animasyon seti değil." if language == "tr" else "Pose drawings; not a complete animation set."), Vector2(280, 663), 18, base)
	queue_redraw()
