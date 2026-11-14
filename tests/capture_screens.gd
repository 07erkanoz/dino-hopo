extends SceneTree
## Acceptance screenshots -> ciktilar/ekran/. Needs a real renderer:
## bash tools/capture.sh   (xvfb-run / headless KWin / $DISPLAY)
## All shots are rendered in SubViewports, independent of the window size.
const OUT := "res://ciktilar/ekran/"
const TouchControls = preload("res://scripts/touch_controls.gd")
var view: SubViewport

func _initialize() -> void:
	call_deferred("capture")

func frames(n: int) -> void:
	for i in n: await physics_frame
	await process_frame

func grab(target: SubViewport) -> Image:
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	return target.get_texture().get_image()

func save(image: Image, file: String) -> void:
	var error := image.save_png(OUT + file)
	if error != OK:
		push_error("could not save " + file)
		quit(1)
	print("SAVED ", file, " ", image.get_size())

func make_view(size: Vector2i) -> SubViewport:
	var v := SubViewport.new()
	v.size = size
	v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	v.size_2d_override = Vector2i(1280, 720) if size.y == 720 else Vector2i.ZERO
	root.add_child(v)
	return v

func new_game(v: SubViewport) -> Node2D:
	for child in v.get_children(): child.queue_free()
	await process_frame
	var game = load("res://scenes/main.tscn").instantiate()
	v.add_child(game)
	await process_frame
	game.sfx_enabled = false
	game.start_game(1, [0])
	await frames(10)
	return game

func place(game: Node2D, x: float, y := 560.0, settle := 50) -> void:
	var hero = game.players[0]
	hero.position = Vector2(x, y)
	hero.checkpoint = hero.position
	hero.velocity = Vector2.ZERO
	hero.grace = 0
	await frames(settle)

func capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	view = make_view(Vector2i(1280, 720))
	# 1) Gameplay frames.
	var game: Node2D = await new_game(view)
	var hero = game.players[0]
	await place(game, 300)
	Input.action_press("move_right")
	await frames(22)
	var start := await grab(view)
	Input.action_release("move_right")
	save(start, "01-oyun-baslangic.png")
	game.targets[0].state = "patrol"
	await place(game, 1420, 560, 30)
	hero.facing = 1
	hero.begin_swing()
	await frames(16)
	save(await grab(view), "02-oyun-savas.png")
	await place(game, 2560, 480, 60)
	save(await grab(view), "03-oyun-selale.png")
	await place(game, 3100, 560, 40)
	save(await grab(view), "04-oyun-pterozor.png")
	# 2) Çağan: one in-level frame per animation (rig frozen at a key pose).
	game = await new_game(view)
	hero = game.players[0]
	for target in game.targets: target.position.x += 3000.0
	await place(game, 1380, 560, 40)
	hero.set_physics_process(false)
	game.set_process(false)
	game.camera.position = hero.position + Vector2(0, -70)
	game.camera.zoom = Vector2(2.6, 2.6)
	for child in game.overlay.get_children(): child.visible = false
	var rig: Node2D = hero.rig
	rig.tree.active = false
	var poses := {"idle": 0.5, "walk": 0.3, "run": 0.2, "jump": 0.12, "fall": 0.2, "land": 0.04, "attack": 0.28, "hurt": 0.1, "die": 1.19, "climb": 0.2}
	var sheet := Image.create(400 * 5, 440 * 2, false, Image.FORMAT_RGBA8)
	var index := 0
	for anim in poses:
		rig.player.play(anim)
		rig.player.seek(poses[anim], true)
		rig.player.pause()
		var lifted: float = 40.0 if anim in ["jump", "fall"] else 0.0
		hero.position.y = 600.0 - lifted
		var image := await grab(view)
		save(image, "cagan-%02d-%s.png" % [index + 1, anim])
		# Thumbnail cropped around the hero (camera centre) for the contact sheet.
		var thumb := image.get_region(Rect2i(390, 60, 500, 550))
		thumb.resize(400, 440)
		sheet.blit_rect(thumb, Rect2i(0, 0, 400, 440), Vector2i((index % 5) * 400, (index / 5) * 440))
		index += 1
	save(sheet, "cagan-animasyonlar.png")
	# 3) Enemies: in-level close-ups and full animation sheets.
	game = await new_game(view)
	await place(game, 200, 560, 10)
	game.set_process(false)
	for child in game.overlay.get_children(): child.visible = false
	game.camera.zoom = Vector2(1.7, 1.7)
	var dino = game.targets[0]
	dino.set_physics_process(false)
	dino.position = Vector2(1700, 600)
	game.camera.position = dino.position + Vector2(0, -110)
	for anim in ["walk", "windup", "hurt", "die"]:
		dino.rig.tree.active = false
		dino.rig.player.play(anim)
		dino.rig.player.seek({"walk": 0.25, "windup": 0.6, "hurt": 0.08, "die": 1.0}[anim], true)
		dino.rig.player.pause()
		save(await grab(view), "dusman-ceratopsian-%s.png" % anim)
	var ptero = game.targets[1]
	ptero.set_physics_process(false)
	ptero.position = Vector2(3240, 360)
	game.camera.position = ptero.position + Vector2(0, 40)
	for anim in ["fly", "swoop", "hurt", "die"]:
		ptero.rig.tree.active = false
		ptero.rig.player.play(anim)
		ptero.rig.player.seek({"fly": 0.15, "swoop": 0.4, "hurt": 0.08, "die": 0.6}[anim], true)
		ptero.rig.player.pause()
		save(await grab(view), "dusman-pterozor-%s.png" % anim)
	# 4) Mobile: touch layout forced on, phone (20:9) and tablet (4:3) aspects.
	TouchControls.force_visible = true
	for item in [[Vector2i(1600, 720), "05-mobil-dokunmatik-20x9.png"], [Vector2i(1280, 720), "05-mobil-dokunmatik-16x9.png"], [Vector2i(960, 720), "05-mobil-dokunmatik-4x3.png"]]:
		var phone := make_view(item[0])
		game = await new_game(phone)
		await place(game, 620, 560, 40)
		game.players[0].has_boomerang = true
		await frames(3)
		save(await grab(phone), item[1])
		phone.queue_free()
	TouchControls.force_visible = false
	# 5) Concept A side by side with the engine frame.
	var concept := (load("res://taslaklar/taslak-a.png") as Texture2D).get_image()
	concept.convert(Image.FORMAT_RGBA8)
	concept.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
	var engine := Image.load_from_file(ProjectSettings.globalize_path(OUT + "02-oyun-savas.png"))
	engine.convert(Image.FORMAT_RGBA8)
	var compare := Image.create(2560 + 24, 720 + 60, false, Image.FORMAT_RGBA8)
	compare.fill(Color("2b1d14"))
	compare.blit_rect(concept, Rect2i(0, 0, 1280, 720), Vector2i(0, 60))
	compare.blit_rect(engine, Rect2i(0, 0, 1280, 720), Vector2i(1304, 60))
	var label_view := make_view(Vector2i(2584, 60))
	label_view.transparent_bg = true
	for item in [["Taslak A (onaylı hedef / approved target)", 20], ["Godot 4 oyun içi / in engine", 1324]]:
		var label := Label.new()
		label.text = item[0]
		label.position = Vector2(item[1], 10)
		label.add_theme_font_size_override("font_size", 30)
		label.add_theme_color_override("font_color", Color("ffe9a8"))
		label_view.add_child(label)
	var labels := await grab(label_view)
	compare.blend_rect(labels, Rect2i(0, 0, 2584, 60), Vector2i.ZERO)
	save(compare, "06-taslak-a-karsilastirma.png")
	print("PASS: screenshots written to ciktilar/ekran/")
	quit(0)
