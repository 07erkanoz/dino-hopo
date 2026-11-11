extends Node2D

const Player = preload("res://scripts/player.gd")
const Art = preload("res://scripts/art.gd")
const Roster = preload("res://scripts/roster.gd")
const CharacterSelect = preload("res://scripts/character_select.gd")
const Forest = preload("res://scripts/forest.gd")
const Dino = preload("res://scripts/dino.gd")
const Boomerang = preload("res://scripts/boomerang.gd")
const RockZone = preload("res://scripts/rock_zone.gd")
const BACKGROUND = preload("res://art/backgrounds/waterfall-valley.png")
const TEXT := {
	"tr": {"solo": "Tek oyuncu", "duo": "İki oyuncu · aynı ekran", "sub": "Çiçekli Vadi · ilk oynanabilir dünya", "help": "P1: A/D · W/Boşluk · F sopa · G bumerang   |   P2: ←/→ · ↑ · K sopa · L bumerang", "fruit": "Meyve", "check": "Kontrol noktası!", "finish": "Çiçekli Vadi tamamlandı!", "back": "Menüye dön", "hint": "Üst yoldaki meyveleri keşfet!"},
	"en": {"solo": "One player", "duo": "Two players · shared screen", "sub": "Blooming Valley · first playable world", "help": "P1: A/D · W/Space · F club · G boomerang   |   P2: ←/→ · ↑ · K club · L boomerang", "fruit": "Fruit", "check": "Checkpoint!", "finish": "Blooming Valley complete!", "back": "Back to menu", "hint": "Explore the fruit on the upper path!"}
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
var level: Dictionary = {}
var selected_heroes: Array = [0, 2]
var targets: Array = []
var power_pickups: Array[Vector2] = []
var secret_found := false
var secret_fade := 1.0
var inventory_label: Label
var region_label: Label
var forest: Node2D

func _ready() -> void:
	level = JSON.parse_string(FileAccess.get_file_as_string("res://world/levels/01.json"))
	soil_texture = AtlasTexture.new()
	soil_texture.atlas = Art.sprite("habitat", 3).atlas
	var soil_bounds := Art.sprite("habitat", 3).region
	soil_texture.region = Rect2(soil_bounds.position + Vector2(24, 100), soil_bounds.size - Vector2(48, 130))
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
		button.pressed.connect(show_character_select.bind(count))
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
	var controls := Button.new()
	controls.text = "Kontroller" if language == "tr" else "Controls"
	controls.custom_minimum_size.y = 46
	controls.pressed.connect(func():
		var dialog := AcceptDialog.new()
		dialog.title = "Kontroller" if language == "tr" else "Controls"
		dialog.dialog_text = tr_text("help") + ("\nW/↑: sarmaşığa tırman · S/↓: in · Boşluk/Shift: ayrıl\nR: kontrol noktasına dön · Esc: menü" if language == "tr" else "\nW/↑: climb vines · S/↓: descend · Space/Shift: jump off\nR: checkpoint · Esc: menu")
		add_child(dialog)
		dialog.popup_centered()
		dialog.confirmed.connect(dialog.queue_free))
	box.add_child(controls)
	queue_redraw()

func show_character_select(count: int) -> void:
	active = false
	if is_instance_valid(world):
		world.queue_free()
	players.clear()
	clear_ui()
	var selection := CharacterSelect.new()
	selection.language = language
	selection.player_count = count
	selection.choices = selected_heroes.duplicate()
	selection.cancelled.connect(show_menu)
	selection.confirmed.connect(func(heroes: Array): start_game(count, heroes))
	overlay.add_child(selection)
	queue_redraw()

func start_game(count: int, heroes: Array = []) -> void:
	clear_ui()
	if is_instance_valid(world): world.queue_free()
	if not heroes.is_empty():
		for i in heroes.size(): selected_heroes[i] = int(heroes[i])
	left_held = false
	right_held = false
	world = Node2D.new()
	add_child(world)
	players.clear()
	targets.clear()
	platforms.clear()
	berries.clear()
	power_pickups.clear()
	score = 0
	completed = false
	saved_checkpoint = false
	secret_found = false
	secret_fade = 1.0
	for box in level.platforms:
		make_platform(Rect2(box[0], box[1], box[2], box[3]))
	for spot in level.fruit:
		berries.append(Vector2(spot[0], spot[1]))
	for spot in [level.boomerang_pickup, [3520, 285]]:
		power_pickups.append(Vector2(spot[0], spot[1]))
	total = berries.size()
	for i in count:
		var player := Player.new()
		player.slot = i
		player.hero_index = selected_heroes[i]
		player.language = language
		player.world_width = level.width
		player.vines = level.vines
		player.club_hit.connect(on_club_hit)
		player.throw_requested.connect(try_throw)
		player.position = Vector2(level.spawns[i][0], level.spawns[i][1])
		player.checkpoint = player.position
		player.collision_layer = 2
		player.collision_mask = 5
		player.z_index = 2
		world.add_child(player)
		players.append(player)
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	world.add_child(camera)
	forest = Forest.new()
	forest.game = self
	world.add_child(forest)
	for spot in level.enemies:
		var dino := Dino.new()
		dino.position = Vector2(spot[0], spot[1])
		dino.species = int(spot[2])
		dino.game = self
		world.add_child(dino)
		targets.append(dino)
	for zone in level.rock_zones:
		var rocks := RockZone.new()
		rocks.position.x = zone[0]
		rocks.origin_y = zone[1]
		rocks.floor_y = zone[2]
		rocks.game = self
		world.add_child(rocks)
	hud = label_at("", Vector2(26, 18), 23, overlay)
	inventory_label = label_at("", Vector2(26, 49), 15, overlay)
	toast = label_at(tr_text("hint"), Vector2(26, 93), 17, overlay)
	region_label = label_at("", Vector2(484, 24), 20, overlay)
	var menu_button := Button.new()
	menu_button.text = "≡"
	menu_button.position = Vector2(1190, 16)
	menu_button.custom_minimum_size = Vector2(64, 54)
	menu_button.pressed.connect(show_menu)
	overlay.add_child(menu_button)
	# Readability panels behind HUD, keep their draw order behind text.
	for bounds in [Rect2(14, 12, 340, 66), Rect2(472, 12, 300, 48), Rect2(14, 89, 600, 31)]:
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
	var actions := ["left", "right", "club", "throw", "jump"]
	for i in actions.size():
		var button := TouchScreenButton.new()
		var circle := CircleShape2D.new()
		circle.radius = 44.0
		button.shape = circle
		button.position = [Vector2(74, 645), Vector2(182, 645), Vector2(966, 645), Vector2(1074, 645), Vector2(1190, 645)][i]
		button.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
		var action: String = actions[i]
		button.pressed.connect(touch_event.bind(action, true))
		button.released.connect(touch_event.bind(action, false))
		overlay.add_child(button)
		var ring := Polygon2D.new()
		var points := PackedVector2Array()
		for j in 32: points.append(Vector2.from_angle(j * TAU / 32.0) * 44)
		ring.polygon = points
		ring.color = Color(1, 0.96, 0.83, 0.75)
		button.add_child(ring)
		if action == "club" or action == "throw":
			var image := Sprite2D.new()
			image.texture = Art.sprite("equipment", 0 if action == "club" else 1)
			image.scale = Vector2.ONE * (50.0 / maxf(image.texture.get_width(), image.texture.get_height()))
			button.add_child(image)
		else:
			var symbol := label_at({"left":"←", "right":"→", "jump":"↑"}[action], Vector2(-24, -35), 48, button)
			symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE

func touch_event(action: String, pressed: bool) -> void:
	if players.is_empty(): return
	if action == "left": left_held = pressed
	if action == "right": right_held = pressed
	if action == "jump": players[0].touch_jump = pressed
	if action == "club": players[0].touch_club = pressed
	if action == "throw": players[0].touch_throw = pressed
	players[0].touch_axis = float(right_held) - float(left_held)

func _process(_delta: float) -> void:
	if not active:
		return
	var center := Vector2.ZERO
	for player in players:
		center += player.position
	center /= players.size()
	camera.position = Vector2(clampf(center.x, 640, float(level.width) - 640), 360)
	for player in players:
		if player.position.x < camera.position.x - 620:
			player.position = Vector2(camera.position.x - 480, 220)
		if player.position.x > level.checkpoint[0] - 10 and not saved_checkpoint:
			saved_checkpoint = true
			for other in players:
				other.checkpoint = Vector2(level.checkpoint[0] + other.slot * 70, level.checkpoint[1])
			toast.text = tr_text("check")
		for i in range(berries.size() - 1, -1, -1):
			if player.position.distance_to(berries[i] + Vector2(0, 35)) < 55:
				berries.remove_at(i)
				score += 1
	if not completed:
		var all_at_exit := true
		for player in players:
			if player.position.x < level.exit[0] - 40:
				all_at_exit = false
		if all_at_exit:
			completed = true
			toast.text = tr_text("finish")
	var inventory: Array[String] = []
	for player in players:
		var state := ("havada" if language == "tr" else "in flight") if player.boomerang_active else (("var" if language == "tr" else "ready") if player.has_boomerang else "—")
		inventory.append(Roster.hero_name(player.hero_index, language) + ": " + state)
		for i in range(power_pickups.size() - 1, -1, -1):
			if not player.has_boomerang and (player.position - Vector2(0, 45)).distance_to(power_pickups[i]) < 48:
				player.has_boomerang = true
				power_pickups.remove_at(i)
				toast.text = "Bumerang buldun! Takılırsa kaybolur." if language == "tr" else "Boomerang found! Get it back or lose it."
		var secret: Array = level.secret
		if Rect2(secret[0], secret[1], secret[2], secret[3]).has_point(player.position):
			if not secret_found:
				secret_found = true
				toast.text = "Gizli çiçek bahçesi!" if language == "tr" else "Secret flower garden!"
		for target in targets:
			if player.grace <= 0 and target.dangerous and absf(target.position.x - player.position.x) < target.contact_radius and absf(target.position.y - player.position.y) < 75:
				player.hurt(target.position.x)
	secret_fade = move_toward(secret_fade, 0.15 if secret_found else 1.0, _delta * 2)
	hud.text = "%s  %d / %d" % [tr_text("fruit"), score, total]
	inventory_label.text = ("Bumerang · " if language == "tr" else "Boomerang · ") + " | ".join(inventory)
	for region in level.regions:
		if center.x >= region.from and center.x < region.to:
			region_label.text = region[language]
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
	var water_t := Time.get_ticks_msec() / 1000.0
	draw_rect(Rect2(2780, -60, 105, 604), Color(0.28, 0.71, 0.74, 0.8))
	for i in 14:
		var y := -60 + fmod(water_t * 220 + i * 47, 600)
		var x := 2788 + posmod(i * 19, 85)
		draw_line(Vector2(x, y), Vector2(x - 2, y + 38), Color(0.9, 1, 0.85, 0.72), 4)
	for i in 10:
		var theta := water_t * 1.2 + i
		draw_circle(Vector2(2825 + sin(theta * 2) * 75, 540 - absf(cos(theta)) * 25), 10 + i % 4, Color(0.89, 1, 0.91, 0.38))
	for rect in platforms:
		if rect.size.y >= 400:
			for x in range(int(rect.position.x), int(rect.end.x), 160):
				var tile_width := minf(160, rect.end.x - x)
				for y in range(int(rect.position.y) + 12, int(rect.end.y), 160):
					draw_texture_rect(soil_texture, Rect2(x, y, tile_width, 161), false)
				var turf := AtlasTexture.new()
				turf.atlas = soil_texture.atlas
				var soil_bounds := Art.sprite("habitat", 3).region
				turf.region = Rect2(soil_bounds.position, Vector2(soil_bounds.size.x, 100))
				draw_texture_rect(turf, Rect2(x, rect.position.y - 12, tile_width + 1, 43), false)
		else:
			# A rooted stone outcrop reaches the floor; no detached floating block.
			draw_texture_rect(Art.sprite("habitat", 2), Rect2(rect.position - Vector2(8, 6), rect.size + Vector2(16, 14)), false)
	for fruit in berries:
		draw_asset("props", 3, fruit + Vector2(0, 15), 34)
	draw_asset("props", 4, Vector2(level.checkpoint[0], 600), 112)
	if saved_checkpoint:
		draw_circle(Vector2(1560, 482), 7, Color("ffdb6b"))
	draw_asset("props", 5, Vector2(level.exit[0], level.exit[1] + 5), 156)
	for vine in level.vines:
		draw_texture_rect(Art.sprite("jungle", 3), Rect2(vine[0] - 32, vine[1], 64, vine[2] - vine[1]), false)
	for pickup in power_pickups:
		var texture := Art.sprite("equipment", 1)
		var size := texture.get_size() * (42.0 / texture.get_width())
		var float_y := sin(Time.get_ticks_msec() / 300.0) * 5
		draw_circle(pickup + Vector2(0, float_y), 30, Color(1, 0.86, 0.35, 0.25))
		draw_texture_rect(texture, Rect2(pickup + Vector2(0,float_y) - size / 2, size), false)
	var cover := Art.sprite("jungle", 2)
	draw_texture_rect(cover, Rect2(665, 202, 190, 146), false, Color(1, 1, 1, secret_fade))

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
		["Kadro / Roster", "res://art/characters/approved-four-heroes-board.png"],
		["Pozlar / Poses", "res://art/characters/approved-four-heroes-poses.png"],
		["Orman / Jungle", "res://art/environment/jungle-modules.png"],
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

func on_club_hit(hero: CharacterBody2D) -> void:
	if not active: return
	for target in targets:
		var offset: Vector2 = target.global_position - hero.global_position
		if absf(offset.x) < target.hit_radius + 65 and offset.x * hero.facing > 0 and absf(offset.y) < 55:
			var ray := PhysicsRayQueryParameters2D.create(hero.global_position + Vector2(0, -45), target.hit_center(), 1)
			if get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): target.stun()

func try_throw(hero: CharacterBody2D) -> bool:
	if not active or not hero.has_boomerang or hero.boomerang_active: return false
	hero.boomerang_active = true
	var projectile := Boomerang.new()
	projectile.hero = hero
	projectile.game = self
	projectile.direction = hero.facing
	projectile.position = hero.position + Vector2(hero.facing * 35, -54)
	world.add_child(projectile)
	return true

func notify_boomerang_lost() -> void:
	if active:
		toast.text = "Bumerang takıldı! Yenisi bir yerde saklı…" if language == "tr" else "Boomerang got stuck! Find another one…"
