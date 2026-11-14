extends Node2D
## Dino Hop! level flow: menu -> character select -> level 01 -> win / game over.
## Level geometry, pickups and enemies come from world/levels/01.json.

const Player = preload("res://scripts/player.gd")
const Art = preload("res://scripts/art.gd")
const Roster = preload("res://scripts/roster.gd")
const HitFeedback = preload("res://scripts/hit_feedback.gd")
const CharacterSelect = preload("res://scripts/character_select.gd")
const Forest = preload("res://scripts/forest.gd")
const Dino = preload("res://scripts/dino.gd")
const Boomerang = preload("res://scripts/boomerang.gd")
const RockZone = preload("res://scripts/rock_zone.gd")
const Hud = preload("res://scripts/hud.gd")
const TouchControls = preload("res://scripts/touch_controls.gd")
const MENU_ART = preload("res://art/v2/parallax/02-distant-mountains-falls.png")
const MENU_SKY = preload("res://art/v2/parallax/01-sky.png")
const START_LIVES := 3
const POINTS := {"fruit": 100, "meat": 500, "egg": 300, "star": 1000, "tablet": 2000, "heart": 200}
const TEXT := {
	"tr": {"solo": "Tek oyuncu", "duo": "İki oyuncu · aynı ekran", "sub": "Çiçekli Vadi · bölüm 1", "help": "Hareket: A/D veya ←/→ · Zıpla: Boşluk/W/↑ · Vur: F/J/X · Bumerang: G/K/C · Gamepad: sol çubuk, A zıpla, X vur, Y bumerang", "fruit": "Meyve", "check": "Kontrol noktası!", "finish": "Bölüm tamamlandı!", "back": "Menüye dön", "hint": "Sağa ilerle, meyveleri topla! Üst yolda bir sır var…", "again": "Tekrar oyna", "over": "Oyun bitti", "restart": "Yeniden başla", "score": "Puan", "secret": "Gizli alan", "enemies": "Yenilen düşman", "lives": "Can", "lost": "Bir can gitti!"},
	"en": {"solo": "One player", "duo": "Two players · shared screen", "sub": "Blooming Valley · level 1", "help": "Move: A/D or ←/→ · Jump: Space/W/↑ · Club: F/J/X · Boomerang: G/K/C · Gamepad: left stick, A jump, X club, Y boomerang", "fruit": "Fruit", "check": "Checkpoint!", "finish": "Level complete!", "back": "Back to menu", "hint": "Head right and grab the fruit! The upper path hides a secret…", "again": "Play again", "over": "Game over", "restart": "Restart", "score": "Score", "secret": "Secret area", "enemies": "Enemies defeated", "lives": "Lives", "lost": "Life lost!"}
}
var language := "tr"
var world: Node2D
var overlay: CanvasLayer
var camera: Camera2D
var players: Array = []
var berries: Array[Vector2] = []
var items: Array = []           # [{pos, kind}] typed pickups (art/v2/pickups)
var platforms: Array[Rect2] = []
var score := 0
var fruit_collected := 0
var total := 0
var lives := START_LIVES
var defeated := 0
var active := false
var completed := false
var game_over := false
var saved_checkpoint := false
var toast: Label
var menu: Control
var hud: Control
var touch: Control
var left_held := false
var right_held := false
var level: Dictionary = {}
var selected_heroes: Array = [0, 2]
var targets: Array = []
var power_pickups: Array[Vector2] = []
var sfx_enabled := true
var hit_events := 0
var last_hit_position := Vector2.ZERO
var impact_shake := 0.0
var secret_found := false
var secret_fade := 1.0
var forest: Node2D
var pickup_layer: Node2D
var time := 0.0
var toast_left := 0.0
var player_count := 1
var textures: Dictionary = {}   # draw() textures must stay referenced after the call

func texture(path: String) -> Texture2D:
	if not textures.has(path): textures[path] = load(path)
	return textures[path]

func _ready() -> void:
	level = JSON.parse_string(FileAccess.get_file_as_string("res://world/levels/01.json"))
	overlay = CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	show_menu()

func tr_text(key: String) -> String:
	return TEXT[language][key]

func clear_ui() -> void:
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	hud = null
	touch = null

func label_at(text: String, where: Vector2, size: int, parent: Node, color := Color("183f43")) -> Label:
	var label := Label.new()
	label.text = text
	label.position = where
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	return style

func free_world() -> void:
	active = false
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	players.clear()
	platforms.clear()
	berries.clear()
	items.clear()
	targets.clear()

func painted_backdrop(parent: Control) -> void:
	for texture in [MENU_SKY, MENU_ART]:
		var painting := TextureRect.new()
		painting.texture = texture
		painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		painting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		painting.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(painting)

func show_menu() -> void:
	free_world()
	clear_ui()
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(menu)
	painted_backdrop(menu)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", panel_style(Color(1.0, 0.95, 0.82, 0.9), Color("8a5a2b")))
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	var title := Label.new()
	title.text = "DINO HOP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color("b65730"))
	title.add_theme_color_override("font_outline_color", Color("fff3c8"))
	title.add_theme_constant_override("outline_size", 10)
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = tr_text("sub")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("183f43"))
	box.add_child(subtitle)
	for count in [1, 2]:
		var button := Button.new()
		button.text = tr_text("solo" if count == 1 else "duo")
		button.custom_minimum_size = Vector2(460, 60)
		button.pressed.connect(show_character_select.bind(count))
		box.add_child(button)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var lang := Button.new()
	lang.text = "Türkçe / English"
	lang.custom_minimum_size = Vector2(225, 48)
	lang.pressed.connect(func():
		language = "en" if language == "tr" else "tr"
		show_menu())
	row.add_child(lang)
	var sound_toggle := Button.new()
	sound_toggle.text = ("Sesler: Açık" if sfx_enabled else "Sesler: Kapalı") if language == "tr" else ("Sound: On" if sfx_enabled else "Sound: Off")
	sound_toggle.custom_minimum_size = Vector2(225, 48)
	sound_toggle.pressed.connect(func():
		sfx_enabled = not sfx_enabled
		show_menu())
	row.add_child(sound_toggle)
	var gallery := Button.new()
	gallery.text = "Çizim galerisi" if language == "tr" else "Art gallery"
	gallery.custom_minimum_size.y = 44
	gallery.pressed.connect(show_gallery)
	box.add_child(gallery)
	var help := Label.new()
	help.text = tr_text("help")
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.custom_minimum_size = Vector2(460, 0)
	help.add_theme_font_size_override("font_size", 14)
	help.add_theme_color_override("font_color", Color("4b3424"))
	box.add_child(help)

func show_character_select(count: int) -> void:
	free_world()
	clear_ui()
	var selection := CharacterSelect.new()
	selection.language = language
	selection.player_count = count
	selection.choices = selected_heroes.duplicate()
	selection.cancelled.connect(show_menu)
	selection.confirmed.connect(func(heroes: Array): start_game(count, heroes))
	overlay.add_child(selection)

func start_game(count: int, heroes: Array = []) -> void:
	clear_ui()
	free_world()
	if not heroes.is_empty():
		for i in heroes.size(): selected_heroes[i] = int(heroes[i])
	player_count = count
	left_held = false
	right_held = false
	world = Node2D.new()
	world.name = "World"
	add_child(world)
	power_pickups.clear()
	score = 0
	fruit_collected = 0
	lives = START_LIVES
	defeated = 0
	hit_events = 0
	impact_shake = 0
	completed = false
	game_over = false
	saved_checkpoint = false
	secret_found = false
	secret_fade = 1.0
	for box in level.platforms:
		make_platform(Rect2(box[0], box[1], box[2], box[3]))
	for spot in level.fruit:
		berries.append(Vector2(spot[0], spot[1]))
	for entry in level.get("pickups", []):
		items.append({"pos": Vector2(entry[0], entry[1]), "kind": String(entry[2])})
	for spot in [level.boomerang_pickup, [3520, 285]]:
		power_pickups.append(Vector2(spot[0], spot[1]))
	total = berries.size()
	forest = Forest.new()
	forest.game = self
	world.add_child(forest)
	pickup_layer = Node2D.new()
	pickup_layer.name = "Pickups"
	pickup_layer.z_index = 5
	pickup_layer.draw.connect(draw_pickups)
	world.add_child(pickup_layer)
	for i in count:
		var player := Player.new()
		player.slot = i
		player.hero_index = selected_heroes[i]
		player.language = language
		player.input_prefix = "" if count == 1 else "p%d_" % (i + 1)
		player.sfx_enabled = sfx_enabled
		player.world_width = level.width
		player.kill_y = float(level.get("kill_y", 950))
		player.vines = level.vines
		player.club_hit.connect(on_club_hit)
		player.throw_requested.connect(try_throw)
		player.died.connect(on_player_died)
		player.fell.connect(on_player_fell)
		player.position = Vector2(level.spawns[i][0], level.spawns[i][1])
		player.checkpoint = player.position
		player.collision_layer = 2
		player.collision_mask = 1
		player.z_index = 10
		world.add_child(player)
		players.append(player)
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	camera.limit_left = 0
	camera.limit_right = int(level.width)
	camera.limit_bottom = 900
	camera.position_smoothing_enabled = false
	world.add_child(camera)
	camera.make_current()
	for spot in level.enemies:
		var dino := Dino.new()
		dino.position = Vector2(spot[0], spot[1])
		dino.species = int(spot[2])
		dino.game = self
		dino.z_index = 8
		dino.defeated.connect(on_enemy_defeated)
		world.add_child(dino)
		targets.append(dino)
	for zone in level.rock_zones:
		var rocks := RockZone.new()
		rocks.position.x = zone[0]
		rocks.origin_y = zone[1]
		rocks.floor_y = zone[2]
		rocks.game = self
		rocks.z_index = 9
		world.add_child(rocks)
	hud = Hud.new()
	hud.game = self
	overlay.add_child(hud)
	toast = hud.toast
	show_toast(tr_text("hint"), 4.0)
	touch = TouchControls.new()
	touch.game = self
	overlay.add_child(touch)
	active = true

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
	if is_instance_valid(forest) and is_instance_valid(forest.terrain): forest.terrain.queue_redraw()

func touch_event(action: String, pressed: bool) -> void:
	if players.is_empty(): return
	if action == "left": left_held = pressed
	if action == "right": right_held = pressed
	if action == "jump": players[0].touch_jump = pressed
	if action == "club": players[0].touch_club = pressed
	if action == "throw": players[0].touch_throw = pressed
	players[0].touch_axis = float(right_held) - float(left_held)

func show_toast(text: String, seconds := 2.5) -> void:
	if is_instance_valid(toast):
		toast.text = text
		toast_left = seconds

func add_score(points: int) -> void:
	score += points

func _process(delta: float) -> void:
	time += delta
	if not active:
		return
	toast_left = maxf(0.0, toast_left - delta)
	if is_instance_valid(toast): toast.modulate.a = clampf(toast_left * 2.0, 0.0, 1.0)
	var center := Vector2.ZERO
	var alive_count := 0
	for player in players:
		center += player.position
		alive_count += 1
	center /= maxf(1, alive_count)
	var view := get_viewport_rect().size
	var target_y := clampf(center.y - 170.0, 250.0, 380.0)
	camera.position = Vector2(clampf(center.x + players[0].facing * 60.0, view.x * 0.5, float(level.width) - view.x * 0.5), lerpf(camera.position.y, target_y, minf(1.0, delta * 4.0)))
	impact_shake = move_toward(impact_shake, 0, delta * 36)
	camera.offset = Vector2(sin(time * 61), cos(time * 83) * 0.6) * impact_shake
	for player in players:
		if player.dead: continue
		if players.size() > 1 and player.position.x < camera.position.x - view.x * 0.48:
			player.position = Vector2(camera.position.x - view.x * 0.38, 220)
		if player.position.x > level.checkpoint[0] - 10 and not saved_checkpoint:
			saved_checkpoint = true
			for other in players:
				other.checkpoint = Vector2(level.checkpoint[0] + other.slot * 70, level.checkpoint[1])
			show_toast(tr_text("check"))
		var body: Vector2 = player.position + Vector2(0, -50)
		for i in range(berries.size() - 1, -1, -1):
			if player.position.distance_to(berries[i] + Vector2(0, 35)) < 55 or body.distance_to(berries[i]) < 45:
				berries.remove_at(i)
				fruit_collected += 1
				add_score(POINTS.fruit)
				if sfx_enabled: HitFeedback.play_sound(player, "swing", 1.8, -20)
		for i in range(items.size() - 1, -1, -1):
			if body.distance_to(items[i].pos) < 50:
				collect(player, items[i].kind)
				items.remove_at(i)
		for i in range(power_pickups.size() - 1, -1, -1):
			if not player.has_boomerang and (player.position - Vector2(0, 45)).distance_to(power_pickups[i]) < 48:
				player.has_boomerang = true
				power_pickups.remove_at(i)
				show_toast("Bumerang buldun! Takılırsa kaybolur." if language == "tr" else "Boomerang found! Get it back or lose it.")
		var secret: Array = level.secret
		if Rect2(secret[0], secret[1], secret[2], secret[3]).has_point(player.position) and not secret_found:
			secret_found = true
			add_score(1500)
			show_toast("Gizli çiçek bahçesi! +1500" if language == "tr" else "Secret flower garden! +1500")
		for target in targets:
			if not target.alive or not target.dangerous or player.grace > 0: continue
			if target.species == 0:
				if absf(target.position.x - player.position.x) < target.contact_radius and absf(target.position.y - player.position.y) < 75:
					player.hurt(target.position.x)
			elif target.global_position.distance_to(body) < target.contact_radius:
				player.hurt(target.position.x)
	if not completed and not game_over:
		var all_at_exit := true
		for player in players:
			if player.position.x < level.exit[0] - 40 or player.dead:
				all_at_exit = false
		if all_at_exit:
			completed = true
			add_score(lives * 1000)
			show_toast(tr_text("finish"))
			show_result(true)
	secret_fade = move_toward(secret_fade, 0.15 if secret_found else 1.0, delta * 2)
	pickup_layer.queue_redraw()

func collect(player: CharacterBody2D, kind: String) -> void:
	add_score(POINTS.get(kind, 100))
	if kind == "heart":
		player.heal(1)
	if kind == "star":
		player.grace = maxf(player.grace, 4.0)
		show_toast("Yıldız: kısa süre dokunulmazsın!" if language == "tr" else "Star: briefly invincible!")
	if kind == "tablet":
		show_toast("Kayıp taş tablet! +2000" if language == "tr" else "Lost stone tablet! +2000")
	if sfx_enabled: HitFeedback.play_sound(player, "swing", 1.5, -16)

func on_enemy_defeated(enemy: CharacterBody2D) -> void:
	defeated += 1
	add_score(enemy.points)

func on_player_died(player: CharacterBody2D) -> void:
	await get_tree().create_timer(1.5, false, true).timeout
	if not is_instance_valid(player) or not active or completed: return
	lose_life(player)

func on_player_fell(player: CharacterBody2D) -> void:
	if not active or completed: return
	lose_life(player, false)

func lose_life(player: CharacterBody2D, respawn := true) -> void:
	lives -= 1
	if lives <= 0:
		lives = 0
		game_over = true
		player.dead = true
		show_result(false)
		return
	if respawn: player.respawn()
	show_toast(tr_text("lost"))

func show_result(won: bool) -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.08, 0.05, 0.02, 0.45)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_child(center)
	var card := PanelContainer.new()
	card.name = "ResultCard"
	card.add_theme_stylebox_override("panel", panel_style(Color(1.0, 0.95, 0.82, 0.96), Color("8a5a2b")))
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)
	var title := Label.new()
	title.text = tr_text("finish") if won else tr_text("over")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("b65730") if won else Color("7a2f22"))
	box.add_child(title)
	for line in ["%s: %06d" % [tr_text("score"), score], "%s: %d / %d" % [tr_text("fruit"), fruit_collected, total],
		"%s: %d / %d" % [tr_text("enemies"), defeated, targets.size()], "%s: %s" % [tr_text("secret"), ("✓" if secret_found else "—")]]:
		var label := Label.new()
		label.text = line
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_color", Color("183f43"))
		box.add_child(label)
	var again := Button.new()
	again.name = "Again"
	again.text = tr_text("again") if won else tr_text("restart")
	again.custom_minimum_size = Vector2(380, 56)
	again.pressed.connect(func(): start_game(player_count))
	box.add_child(again)
	var back := Button.new()
	back.text = tr_text("back")
	back.custom_minimum_size = Vector2(380, 48)
	back.pressed.connect(show_menu)
	box.add_child(back)
	again.call_deferred("grab_focus")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and (active or completed):
		show_menu()
	elif event.is_action_pressed("restart") and active and not completed and not game_over:
		for player in players:
			player.respawn()
	elif event is InputEventScreenTouch and is_instance_valid(touch) and not touch.visible:
		touch.visible = true

func draw_pickups() -> void:
	var canvas := pickup_layer
	var bob := sin(time * 3.0) * 4.0
	var fruit := texture("res://art/v2/pickups/fruit.png")
	for spot in berries:
		var size := Vector2(34, 38)
		canvas.draw_texture_rect(fruit, Rect2(spot + Vector2(0, bob) - size * 0.5, size), false)
	for item in items:
		var image := texture("res://art/v2/pickups/%s.png" % item.kind)
		var size := image.get_size() * (46.0 / image.get_height())
		var glow := 0.18 + 0.08 * sin(time * 5.0)
		canvas.draw_circle(item.pos + Vector2(0, bob), 30, Color(1, 0.92, 0.5, glow))
		canvas.draw_texture_rect(image, Rect2(item.pos + Vector2(0, bob) - size * 0.5, size), false)
	for pickup in power_pickups:
		var boomerang := Art.sprite("equipment", 1)
		var size := boomerang.get_size() * (42.0 / boomerang.get_width())
		canvas.draw_circle(pickup + Vector2(0, bob), 30, Color(1, 0.86, 0.35, 0.25))
		canvas.draw_texture_rect(boomerang, Rect2(pickup + Vector2(0, bob) - size / 2, size), false)
	# Checkpoint totem and exit gate (temporary: no dedicated v2 art yet).
	var cp := Vector2(level.checkpoint[0], 600)
	canvas.draw_line(cp, cp + Vector2(0, -110), Color("6b4223"), 8)
	var flag := PackedVector2Array([cp + Vector2(4, -108), cp + Vector2(58 + sin(time * 4.0) * 4.0, -94), cp + Vector2(4, -78)])
	canvas.draw_colored_polygon(flag, Color("3fb6a8") if saved_checkpoint else Color("d9c9a3"))
	var exit := Vector2(level.exit[0], level.exit[1])
	for side in [-1.0, 1.0]:
		canvas.draw_line(exit + Vector2(side * 46, 0), exit + Vector2(side * 40, -150), Color("6b4223"), 14)
	canvas.draw_line(exit + Vector2(-60, -150), exit + Vector2(60, -150), Color("7d522c"), 16)
	var tablet := texture("res://art/v2/pickups/tablet.png")
	canvas.draw_texture_rect(tablet, Rect2(exit + Vector2(-26, -205), Vector2(52, 52)), false)
	# Leafy cover over the secret garden fades once discovered.
	var secret: Array = level.secret
	var bush := texture("res://art/v2/terrain/bush.png")
	canvas.draw_texture_rect(bush, Rect2(secret[0] - 10, secret[1] + 20, secret[2] + 20, secret[3] - 10), false, Color(1, 1, 1, secret_fade))

func show_gallery() -> void:
	free_world()
	clear_ui()
	var base := Control.new()
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(base)
	var paper := ColorRect.new()
	paper.color = Color("f6edda")
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.add_child(paper)
	label_at("DINO HOP!  /  " + ("ÇİZİM GALERİSİ" if language == "tr" else "ART GALLERY"), Vector2(30, 18), 32, base)
	var tabs := TabContainer.new()
	tabs.position = Vector2(24, 80)
	tabs.size = Vector2(1232, 555)
	base.add_child(tabs)
	var entries := [
		["Kadro / Roster", "res://art/characters/approved-four-heroes-board.png"],
		["Taslak A / Concept A", "res://taslaklar/taslak-a.png"],
		["Varlıklar / Assets", "res://art/v2/preview-composite.png"],
		["Canlılar / Creatures", "res://art/creatures/creatures-natural-v3.png"]
	]
	for item in entries:
		if not ResourceLoader.exists(item[1]): continue   # review images are not exported
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

func on_club_hit(hero: CharacterBody2D) -> void:
	if not active: return
	var tip: Vector2 = hero.club_tip()
	for target in targets:
		if not target.alive or hero.attack_targets.has(target.get_instance_id()): continue
		var offset: Vector2 = target.global_position - hero.global_position
		if offset.x * hero.attack_facing < 0: continue
		var closest := Geometry2D.get_closest_point_to_segment(target.hit_center(), hero.previous_club_tip, tip)
		if closest.distance_to(target.hit_center()) > target.hit_radius + 12: continue
		var ray := PhysicsRayQueryParameters2D.create(hero.global_position + Vector2(0,-65), closest, 1)
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): continue
		hero.attack_targets[target.get_instance_id()] = true
		hero.attack_connected = true
		hero.hit_pause = 0.045
		register_hit(target, hero.global_position, closest, 1.0)

func register_hit(target: Node2D, from: Vector2, contact: Vector2, strength: float) -> void:
	target.receive_hit(from, strength)
	hit_events += 1
	last_hit_position = contact
	impact_shake = 3.5 * strength
	var feedback := HitFeedback.new()
	feedback.position = contact
	feedback.side = 1 if target.position.x > from.x else -1
	feedback.variant = hit_events
	feedback.sound_enabled = sfx_enabled
	feedback.z_index = 20
	world.add_child(feedback)

func try_throw(hero: CharacterBody2D) -> bool:
	if not active or not hero.has_boomerang or hero.boomerang_active: return false
	hero.boomerang_active = true
	var projectile := Boomerang.new()
	projectile.hero = hero
	projectile.game = self
	projectile.direction = hero.facing
	projectile.position = hero.position + Vector2(hero.facing * 35, -54)
	projectile.z_index = 12
	world.add_child(projectile)
	return true

func notify_boomerang_lost() -> void:
	if active:
		show_toast("Bumerang takıldı! Yenisi bir yerde saklı…" if language == "tr" else "Boomerang got stuck! Find another one…")
