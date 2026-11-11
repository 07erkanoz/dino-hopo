extends Node2D
## Map review tool; intentionally no game controller, enemies or final art.
const Plan = preload("res://scripts/nature_plan.gd")
var data: Dictionary
var camera: Camera2D
var overlay: CanvasLayer
var language := "tr"
var show_routes := true
var dragging := false
var overview_zoom := 0.19
var ready_for_review := false

func _ready() -> void:
	data = Plan.read()
	camera = Camera2D.new()
	add_child(camera)
	overlay = CanvasLayer.new()
	add_child(overlay)
	build_ui()
	overview()
	ready_for_review = true
	queue_redraw()

func text(value: String, position_at: Vector2, size: int = 18) -> Label:
	var label := Label.new()
	label.text = value
	label.position = position_at
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("2e4540"))
	overlay.add_child(label)
	return label

func build_ui() -> void:
	for child in overlay.get_children(): child.queue_free()
	var panel := ColorRect.new()
	panel.color = Color("f4f1e6")
	panel.position = Vector2.ZERO
	panel.size = Vector2(1280, 152)
	overlay.add_child(panel)
	text("DINO HOP!  /  " + ("HARİTA ATÖLYESİ" if language == "tr" else "MAP WORKSPACE"), Vector2(22,12), 27)
	text(data.notes[language], Vector2(22,50), 17)
	var labels := ["Genel plan", "Giriş", "Kökler", "Nehir", "Şelale", "Mağara", "Çıkış"] if language == "tr" else ["Overview", "Grove", "Roots", "River", "Falls", "Cavern", "Exit"]
	for i in labels.size():
		var button := Button.new()
		button.text = labels[i]
		button.position = Vector2(22+i*139,92)
		button.size = Vector2(130,42)
		if i == 0: button.pressed.connect(overview)
		else: button.pressed.connect(focus_region.bind(i-1))
		overlay.add_child(button)
	var lang := Button.new()
	lang.text = "TR / EN"
	lang.position = Vector2(1158,16)
	lang.size = Vector2(100,40)
	lang.pressed.connect(func():
		language = "en" if language == "tr" else "tr"
		build_ui()
		queue_redraw())
	overlay.add_child(lang)
	text("Sürükle: gezdir · Tekerlek: yakınlaş · R: genel plan · Tab: rotalar" if language == "tr" else "Drag: pan · Wheel: zoom · R: overview · Tab: routes", Vector2(22,674), 17)
	text("1 Harita → 2 Doğa → 3 Engeller → 4 Canlılar → 5 Bulmaca/Görev → 6 Hareket" if language == "tr" else "1 Map → 2 Nature → 3 Obstacles → 4 Creatures → 5 Puzzles/Quests → 6 Motion", Vector2(22,699), 13)

func overview() -> void:
	camera.zoom = Vector2.ONE * overview_zoom
	camera.position = Vector2(float(data.width)/2, 780)
	queue_redraw()

func focus_region(index: int) -> void:
	var region: Dictionary = data.regions[index]
	camera.zoom = Vector2.ONE * 0.72
	camera.position = Vector2((region.from+region.to)/2.0, 750)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: dragging = event.pressed
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var factor := 1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0/1.15
			camera.zoom = Vector2.ONE * clampf(camera.zoom.x*factor, 0.16, 1.2)
	elif event is InputEventMouseMotion and dragging:
		camera.position -= event.relative / camera.zoom
	elif event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_R: overview()
		if event.physical_keycode == KEY_TAB:
			show_routes = not show_routes
			queue_redraw()

func line(points: Array, color: Color, width: float) -> void:
	var poly := PackedVector2Array()
	for point in points: poly.append(Vector2(point[0], point[1]))
	draw_polyline(poly, color, width, true)

func _draw() -> void:
	if data.is_empty(): return
	draw_rect(Rect2(-4000,-4000,16000,10000), Color("f4f1e6"))
	for x in range(0,int(data.width)+1,256):
		draw_line(Vector2(x,180),Vector2(x,1536),Color("d9dfd0"),2)
	for y in range(256,1537,256):
		draw_line(Vector2(0,y),Vector2(data.width,y),Color("d9dfd0"),2)
	for i in data.regions.size():
		var region: Dictionary = data.regions[i]
		draw_rect(Rect2(region.from,220,region.to-region.from,1150),Color(0.7,0.79,0.62,0.08 if i%2 else 0.2))
		draw_string(ThemeDB.fallback_font,Vector2(region.from+35,300),region.name[language],HORIZONTAL_ALIGNMENT_LEFT,-1,52,Color("2e4540"))
		draw_string(ThemeDB.fallback_font,Vector2(region.from+35,350),str(region.from)+"–"+str(region.to),HORIZONTAL_ALIGNMENT_LEFT,-1,30,Color("68806c"))
	var ground := PackedVector2Array()
	for point in data.surface: ground.append(Vector2(point[0],point[1]))
	ground.append(Vector2(data.width,1536))
	ground.append(Vector2(0,1536))
	draw_colored_polygon(ground,Color("d6c1a0"))
	line(data.surface,Color("697d4b"),14)
	var river: Dictionary = data.water.river
	draw_rect(Rect2(river.left,river.surface_y,river.right-river.left,river.bottom_y-river.surface_y),Color("7bbaba"))
	var falls: Dictionary = data.water.waterfall
	var headland := PackedVector2Array()
	for point in falls.headland: headland.append(Vector2(point[0],point[1]))
	draw_colored_polygon(headland,Color("b9ae8e"))
	line(falls.feed_stream,Color("4c999e"),24)
	line([falls.source,falls.lip,falls.pool],Color("4c999e"),falls.width)
	line(falls.outlet,Color("78b7b5"),30)
	var cave: Array = data.cavern.bounds
	draw_rect(Rect2(cave[0],cave[1],cave[2],cave[3]),Color("a09b83"))
	draw_string(ThemeDB.fallback_font,Vector2(cave[0]+35,cave[1]+120),"ALT GEÇİT" if language=="tr" else "LOWER PASSAGE",HORIZONTAL_ALIGNMENT_LEFT,-1,32,Color("f4f1e6"))
	# Tree roots are sampled from the terrain. A vine's start is a branch socket.
	for tree in data.trees:
		var root := Plan.tree_root(data,tree)
		var crown := root-Vector2(0,tree.height)
		draw_line(root,crown,Color("667556"),16)
		for branch in tree.branches:
			var anchor := root+Vector2(branch.offset[0],branch.offset[1])
			draw_line(root-Vector2(0,absf(branch.offset[1])*0.65),anchor,Color("667556"),10)
			draw_circle(anchor,14,Color("547e5c"))
		draw_string(ThemeDB.fallback_font,root+Vector2(15,50),tree.id,HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("526747"))
	for vine in data.vines:
		var anchor := Plan.vine_anchor(data,vine)
		draw_line(anchor,anchor+Vector2(0,vine.length),Color("4d9699"),8)
		draw_circle(anchor+Vector2(0,vine.length),11,Color("4d9699"))
	if show_routes:
		for route in data.routes:
			line(route.points,Color(route.color),9)
			for point in route.points: draw_circle(Vector2(point[0],point[1]),11,Color(route.color))
	# A technical human-size ruler, not a playable hero.
	draw_line(Vector2(120,1120),Vector2(120,992),Color("5d4c40"),8)
	draw_string(ThemeDB.fallback_font,Vector2(155,1055),"128",HORIZONTAL_ALIGNMENT_LEFT,-1,32,Color("5d4c40"))
