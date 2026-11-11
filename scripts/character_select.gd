extends Control
signal confirmed(heroes: Array)
signal cancelled
const Art = preload("res://scripts/art.gd")
const Roster = preload("res://scripts/roster.gd")
const BACKGROUND = preload("res://art/backgrounds/waterfall-valley.png")
var language := "tr"
var player_count := 1
var choices: Array = [0, 2]
var selecting := 0
var player_buttons: Array[Button] = []
var cards: Array[Button] = []
var start_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var painting := TextureRect.new()
	painting.texture = BACKGROUND
	painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	painting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(painting)
	var veil := ColorRect.new()
	veil.color = Color(1, 0.96, 0.86, 0.88)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	text_at("DINO HOP!", Vector2(32, 14), 34)
	text_at("KAHRAMANINI SEÇ" if language == "tr" else "CHOOSE YOUR HERO", Vector2(32, 58), 38)
	for slot in player_count:
		var button := Button.new()
		button.position = Vector2(32 + slot * 610, 118)
		button.size = Vector2(596, 56)
		button.pressed.connect(select_player.bind(slot))
		add_child(button)
		for color_state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			button.add_theme_color_override(color_state, Color("453b32"))
		player_buttons.append(button)
	for i in 4:
		var button := Button.new()
		button.position = Vector2(32 + i * 308, 192)
		button.size = Vector2(292, 370)
		button.pressed.connect(choose.bind(i))
		button.add_theme_stylebox_override("normal", style(Color("fff7e2"), Color("cfb594")))
		button.add_theme_stylebox_override("hover", style(Color("fff1ca"), Color("a87539")))
		button.add_theme_stylebox_override("focus", style(Color(0,0,0,0), Color("24897f"), 4))
		add_child(button)
		cards.append(button)
		var image := Sprite2D.new()
		image.texture = Art.sprite("heroes", Roster.frame(i, 0))
		image.position = Vector2(146, 268)
		image.offset.y = -image.texture.get_height() / 2.0
		image.scale = Vector2.ONE * (244.0 / image.texture.get_height())
		button.add_child(image)
		var name_label := text_at(Roster.hero_name(i, language), Vector2(0, 287), 27, button)
		name_label.size.x = 292
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var detail := text_at(Roster.HEROES[i].id + " · " + Roster.HEROES[i][language], Vector2(0, 326), 18, button)
		detail.size.x = 292
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_at("Tüm kahramanlar aynı hareket ve silahları kullanır." if language == "tr" else "Every hero shares the same moves and weapons.", Vector2(32, 579), 22)
	var back := Button.new()
	back.text = "Geri" if language == "tr" else "Back"
	back.position = Vector2(32, 630)
	back.size = Vector2(220, 64)
	back.pressed.connect(func(): cancelled.emit())
	add_child(back)
	start_button = Button.new()
	start_button.text = "MACERAYA BAŞLA" if language == "tr" else "START ADVENTURE"
	start_button.position = Vector2(824, 630)
	start_button.size = Vector2(424, 64)
	start_button.add_theme_stylebox_override("normal", style(Color("247f76"), Color("15594f")))
	start_button.pressed.connect(func(): confirmed.emit(choices.slice(0, player_count)))
	add_child(start_button)
	refresh()
	cards[choices[0]].grab_focus()

func text_at(value: String, location: Vector2, size: int, parent: Node = null) -> Label:
	if parent == null:
		parent = self
	var label := Label.new()
	label.text = value
	label.position = location
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("453b32"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func style(fill: Color, border: Color, width: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(16)
	return box

func select_player(slot: int) -> void:
	selecting = slot
	refresh()

func choose(hero: int) -> void:
	choices[selecting] = hero
	if player_count == 2:
		selecting = 1 - selecting
	refresh()

func refresh() -> void:
	for slot in player_count:
		player_buttons[slot].text = ("Oyuncu " if language == "tr" else "Player ") + str(slot + 1) + " · " + Roster.hero_name(choices[slot], language)
		player_buttons[slot].add_theme_stylebox_override("normal", style(Color("f6d178") if selecting == slot else Color("fff7e2"), Color("a4773f")))
	for i in cards.size():
		cards[i].add_theme_stylebox_override("normal", style(Color("e3f1dc") if i in choices.slice(0, player_count) else Color("fff7e2"), Color("24897f") if i == choices[selecting] else Color("cfb594"), 4 if i == choices[selecting] else 2))
