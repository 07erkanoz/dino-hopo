extends Control
## In-game HUD (art/v2/ui): hearts + lives (top-left), score (top-centre),
## fruit counter (top-right). Anchored so it follows any screen aspect.

var game: Node2D
var hearts: Array[TextureRect] = []
var lives_label: Label
var score_label: Label
var fruit_label: Label
var toast: Label
var region_label: Label

func _init() -> void:
	name = "Hud"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func styled(size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("ffe9a8"))
	label.add_theme_color_override("font_outline_color", Color("3b2414"))
	label.add_theme_constant_override("outline_size", 8)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func panel(texture_path: String, preset: int, size: Vector2, offset: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = load(texture_path)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	rect.set_anchors_preset(preset)
	rect.size = size
	match preset:
		Control.PRESET_TOP_LEFT: rect.position = offset
		Control.PRESET_CENTER_TOP: rect.offset_left = -size.x * 0.5; rect.offset_right = size.x * 0.5; rect.offset_top = offset.y; rect.offset_bottom = offset.y + size.y
		Control.PRESET_TOP_RIGHT: rect.offset_left = -size.x - offset.x; rect.offset_right = -offset.x; rect.offset_top = offset.y; rect.offset_bottom = offset.y + size.y
	return rect

func _ready() -> void:
	var lives_panel := panel("res://art/v2/ui/lives-panel.png", Control.PRESET_TOP_LEFT, Vector2(250, 92), Vector2(6, 0))
	for i in 3:
		var heart := TextureRect.new()
		heart.texture = load("res://art/v2/ui/life-heart.png")
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.position = Vector2(34 + i * 44, 26)
		heart.size = Vector2(40, 36)
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lives_panel.add_child(heart)
		hearts.append(heart)
	lives_label = styled(22)
	lives_label.position = Vector2(170, 24)
	lives_label.size = Vector2(70, 40)
	lives_panel.add_child(lives_label)
	var score_panel := panel("res://art/v2/ui/score-panel.png", Control.PRESET_CENTER_TOP, Vector2(300, 92), Vector2(0, 0))
	score_label = styled(34)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	score_label.offset_top = 4
	score_panel.add_child(score_label)
	var fruit_panel := panel("res://art/v2/ui/score-panel.png", Control.PRESET_TOP_RIGHT, Vector2(200, 84), Vector2(8, 2))
	var fruit_icon := TextureRect.new()
	fruit_icon.texture = load("res://art/v2/pickups/fruit.png")
	fruit_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fruit_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fruit_icon.position = Vector2(30, 18)
	fruit_icon.size = Vector2(44, 46)
	fruit_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fruit_panel.add_child(fruit_icon)
	fruit_label = styled(30)
	fruit_label.position = Vector2(80, 18)
	fruit_label.size = Vector2(100, 46)
	fruit_panel.add_child(fruit_label)
	toast = styled(22)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast.offset_left = -400
	toast.offset_right = 400
	toast.offset_top = 96
	toast.offset_bottom = 130
	add_child(toast)
	region_label = styled(16)
	region_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	region_label.position = Vector2(20, 92)
	add_child(region_label)

func _process(_delta: float) -> void:
	if not is_instance_valid(game) or game.players.is_empty(): return
	var hero = game.players[0]
	for i in hearts.size():
		hearts[i].modulate = Color(1, 1, 1, 1) if i < hero.health else Color(0.3, 0.25, 0.25, 0.55)
	lives_label.text = "×%d" % game.lives
	score_label.text = "%06d" % game.score
	fruit_label.text = "×%d" % game.fruit_collected
	for region in game.level.regions:
		if hero.position.x >= region.from and hero.position.x < region.to:
			region_label.text = region[game.language]
