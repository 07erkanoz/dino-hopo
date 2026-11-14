extends Node2D
## Level nature (Concept A): four Parallax2D layers from art/v2/parallax,
## painted terrain tiles for ground/pillars/floating rocks, animated water and
## waterfalls, wind-swayed vegetation and a warm CanvasModulate grade.
## Collision stays in game.gd (StaticBody2D per level rectangle); this node
## only draws what the bodies already are.

const V2 := "res://art/v2/"
const SCREEN_SCALE := 720.0 / 1080.0
const LAYERS := [
	["01-sky", 0.0, -60, false],
	["02-distant-mountains-falls", 0.18, 0, false],
	["03-middle-forest", 0.45, 30, false],
	["04-near-foliage", 1.25, 120, true],
]
const WIND_SHADER := """shader_type canvas_item;
uniform float strength = 6.0;
uniform float speed = 1.3;
void vertex() {
	float seed = MODEL_MATRIX[3].x * 0.013;
	float bend = pow(1.0 - UV.y, 1.6);
	VERTEX.x += sin(TIME * speed + seed) * strength * bend + sin(TIME * speed * 2.3 + seed * 1.7) * strength * 0.25 * bend;
}"""
const WATER_SHADER := """shader_type canvas_item;
uniform float speed = 0.05;
void fragment() {
	vec2 uv = UV;
	uv.x += TIME * speed + sin(UV.y * 9.0 + TIME * 2.0) * 0.01;
	uv.y += sin(UV.x * 20.0 + TIME * 1.7) * 0.012;
	vec4 c = texture(TEXTURE, uv);
	float glint = smoothstep(0.82, 1.0, sin(UV.x * 40.0 - TIME * 3.0 + UV.y * 8.0)) * 0.18;
	COLOR = vec4(c.rgb + glint, c.a * COLOR.a);
}"""
const FALL_SHADER := """shader_type canvas_item;
void fragment() {
	vec2 uv = UV;
	uv.x += sin(UV.y * 30.0 - TIME * 6.0) * 0.004;
	vec4 c = texture(TEXTURE, uv);
	float streak = smoothstep(0.6, 1.0, sin(UV.y * 26.0 - TIME * 9.0 + sin(UV.x * 17.0) * 3.0));
	float foam = smoothstep(0.75, 1.0, UV.y) * 0.1 * sin(TIME * 8.0 + UV.x * 30.0);
	COLOR = vec4(c.rgb + vec3(streak * 0.16 * c.a) + foam, c.a);
}"""

var game: Node2D
var depth_layers: Array[Parallax2D] = []
var textures: Dictionary = {}
var wind_material: ShaderMaterial
var water_material: ShaderMaterial
var fall_material: ShaderMaterial
var terrain: Node2D
var rng := RandomNumberGenerator.new()

func tex(path: String) -> Texture2D:
	if not textures.has(path): textures[path] = load(V2 + path)
	return textures[path]

func _ready() -> void:
	rng.seed = 140
	wind_material = shader_material(WIND_SHADER)
	water_material = shader_material(WATER_SHADER)
	fall_material = shader_material(FALL_SHADER)
	var grade := CanvasModulate.new()
	grade.color = Color(1.0, 0.975, 0.92)
	add_child(grade)
	build_parallax()
	terrain = Node2D.new()
	terrain.name = "Terrain"
	terrain.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	terrain.draw.connect(draw_terrain)
	add_child(terrain)
	build_water()
	build_scenery()

func shader_material(code: String) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = code
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func build_parallax() -> void:
	for layer in LAYERS:
		var parallax := Parallax2D.new()
		parallax.name = "Parallax_" + layer[0]
		var ratio: float = layer[1]
		parallax.scroll_scale = Vector2(ratio, ratio * 0.5 if ratio < 1.0 else 1.0)
		parallax.repeat_size = Vector2(1920.0 * SCREEN_SCALE, 0)
		parallax.repeat_times = 3
		parallax.ignore_camera_scroll = false
		var sprite := Sprite2D.new()
		sprite.texture = tex("parallax/%s.png" % layer[0])
		sprite.centered = false
		sprite.scale = Vector2.ONE * SCREEN_SCALE
		sprite.position = Vector2(0, layer[2])
		if layer[0] == "01-sky":
			sprite.scale = Vector2.ONE * SCREEN_SCALE * 1.15
			sprite.position = Vector2(0, -150)
			parallax.repeat_size = Vector2(1920.0 * SCREEN_SCALE * 1.15, 0)
		parallax.add_child(sprite)
		if layer[3]:
			# Near foliage is the foreground layer: in front of actors, below the walk line.
			parallax.z_index = 80
			sprite.modulate = Color(0.86, 0.9, 0.82)
			sprite.material = wind_material
		else:
			parallax.z_index = -100 + depth_layers.size()
		add_child(parallax)
		depth_layers.append(parallax)

## Ground tops in world space, sorted by x: [from, to, top].
func ground_segments() -> Array:
	var out := []
	for rect in game.platforms:
		if rect.size.y >= 400: out.append([rect.position.x, rect.end.x, rect.position.y])
	out.sort_custom(func(a, b): return a[0] < b[0])
	return out

func surface_at(x: float) -> float:
	var best := 2000.0
	for rect in game.platforms:
		if x >= rect.position.x and x <= rect.end.x and rect.size.y >= 400: best = minf(best, rect.position.y)
	return best

func draw_terrain() -> void:
	var grass := tex("terrain/grass-top.png")
	var soil := tex("terrain/soil-fill.png")
	var rock := tex("terrain/rock-platform.png")
	var stones := tex("terrain/rocks.png")
	var ordered: Array = game.platforms.duplicate()
	ordered.sort_custom(func(a, b): return a.size.y > b.size.y)   # ground first, pillars on top
	for rect in ordered:
		var ground: bool = rect.size.y >= 400
		var reaches_ground: bool = ground or rect.end.y >= surface_at(rect.get_center().x) - 1.0
		if not reaches_ground:
			# Floating rock: painted island, its grass line on the collision top.
			var s: float = (rect.size.x + 36.0) / 339.0
			terrain.draw_texture_rect(rock, Rect2(rect.position.x - 18.0 - 4.0 * s, rect.position.y - 30.0 * s, 347.0 * s, 237.0 * s), false)
			continue
		var shade := Color(1, 1, 1) if ground else Color(0.84, 0.78, 0.74)
		var overhang := 0.0 if ground else 10.0
		# Soil body (tiled at half resolution), then the grass cap with hanging leaves.
		terrain.draw_set_transform(Vector2.ZERO, 0, Vector2(0.5, 0.5))
		var body := Rect2(rect.position.x * 2.0, (rect.position.y + 50) * 2.0, rect.size.x * 2.0, (rect.size.y - 50) * 2.0)
		terrain.draw_texture_rect(soil, body, true, shade)
		var cap := Rect2((rect.position.x - overhang) * 2.0, (rect.position.y - 18) * 2.0, (rect.size.x + overhang * 2.0) * 2.0, 256)
		terrain.draw_texture_rect(grass, cap, true, Color(1, 1, 1) if ground else Color(0.97, 0.95, 0.9))
		terrain.draw_set_transform(Vector2.ZERO)
		if not ground:
			# Volume: shadow under the cap, darker flanks, boulders at the foot.
			terrain.draw_rect(Rect2(rect.position.x, rect.position.y + 100, rect.size.x, 14), Color(0.2, 0.08, 0.02, 0.18))
			terrain.draw_rect(Rect2(rect.position.x, rect.position.y + 40, 12, rect.size.y - 40), Color(0.25, 0.12, 0.05, 0.28))
			terrain.draw_rect(Rect2(rect.end.x - 16, rect.position.y + 40, 16, rect.size.y - 40), Color(0.2, 0.08, 0.03, 0.38))
			if rect.size.y > 90:
				terrain.draw_texture_rect(stones, Rect2(rect.position.x - 26, rect.end.y - 40, 70, 40), false)
				terrain.draw_texture_rect(stones, Rect2(rect.end.x - 40, rect.end.y - 34, -60, 36), false)
	for segment in ground_segments():
		# Cliff edges: a darker lip where ground ends at water.
		for x in [segment[0], segment[1]]:
			var left: bool = x == segment[1]
			terrain.draw_rect(Rect2(x - (12 if left else 0), segment[2] + 30, 12, 500), Color(0.22, 0.1, 0.04, 0.35))

func build_water() -> void:
	var segments := ground_segments()
	for i in segments.size() - 1:
		var gap_from: float = segments[i][1]
		var gap_to: float = segments[i + 1][0]
		if gap_to - gap_from < 20: continue
		var deep := ColorRect.new()
		deep.color = Color("1d8c93")
		deep.position = Vector2(gap_from, 676)
		deep.size = Vector2(gap_to - gap_from, 420)
		deep.z_index = -5
		add_child(deep)
		var surface := TextureRect.new()
		surface.texture = tex("terrain/water-surface.png")
		surface.stretch_mode = TextureRect.STRETCH_TILE
		surface.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		surface.material = water_material
		surface.position = Vector2(gap_from, 640)
		surface.size = Vector2(gap_to - gap_from, 72)
		surface.scale = Vector2.ONE
		surface.z_index = -4
		surface.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		add_child(surface)
		var top: float = minf(segments[i][2], segments[i + 1][2])
		add_waterfall(Vector2((gap_from + gap_to) * 0.5, top - 150), 660.0, (gap_to - gap_from) / 318.0 * 0.95)

## Waterfall hanging from a rock ledge (crest attached to the ledge, base in a pool).
func add_waterfall(crest: Vector2, base_y: float, width_scale: float) -> void:
	var fall := Sprite2D.new()
	fall.texture = tex("terrain/waterfall.png")
	fall.centered = false
	var sy := (base_y - crest.y) / 345.0
	fall.scale = Vector2(width_scale, sy)
	fall.position = crest - Vector2(159 * width_scale, 5 * sy)
	fall.material = fall_material
	fall.z_index = -6
	add_child(fall)
	var ledge := Sprite2D.new()
	ledge.texture = tex("terrain/rock-platform.png")
	ledge.centered = false
	var ls := width_scale * 1.25
	ledge.scale = Vector2(ls, ls)
	ledge.position = crest - Vector2(173 * ls, 40 * ls)
	ledge.z_index = -7
	ledge.modulate = Color(0.85, 0.82, 0.8)
	add_child(ledge)

func prop(path: String, foot: Vector2, height: float, z := -3, sway := false, flip := false, tint := Color.WHITE) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = tex(path)
	sprite.centered = false
	var image_size := sprite.texture.get_size()
	var s := height / image_size.y
	sprite.scale = Vector2(-s if flip else s, s)
	sprite.position = foot - Vector2((image_size.x * 0.5) * (-s if flip else s), image_size.y * s * 0.985)
	sprite.z_index = z
	sprite.modulate = tint
	if sway: sprite.material = wind_material
	add_child(sprite)
	return sprite

func build_scenery() -> void:
	var level: Dictionary = game.level
	# Backdrop waterfall cliff in the rocky-falls region.
	var cliff_x := 2830.0
	var cliff_top := 190.0
	var cliff := Polygon2D.new()
	cliff.polygon = PackedVector2Array([Vector2(cliff_x - 120, 536), Vector2(cliff_x - 105, cliff_top + 30), Vector2(cliff_x - 60, cliff_top), Vector2(cliff_x + 70, cliff_top + 6), Vector2(cliff_x + 115, cliff_top + 40), Vector2(cliff_x + 125, 536)])
	cliff.texture = tex("terrain/soil-fill.png")
	cliff.texture_scale = Vector2(2, 2)
	cliff.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	cliff.color = Color(0.78, 0.72, 0.68)
	cliff.z_index = -9
	add_child(cliff)
	add_waterfall(Vector2(cliff_x, cliff_top + 20), 540.0, 0.62)
	# Trees: roots on the terrain surface; vine tops sit inside a supporting crown.
	for vine in level.vines:
		var ground := surface_at(vine[0] + 40)
		var height: float = (ground - vine[1]) + 120.0
		prop("terrain/tree-crooked.png", Vector2(vine[0] + 40, ground + 4), height, -8, true, int(vine[0]) % 2 == 0)
	for x in [260, 1500, 2480, 3080, 3990, 4500, 4950]:
		var ground := surface_at(x)
		if ground > 1500: continue
		prop("terrain/tree-branching.png", Vector2(x, ground + 4), rng.randf_range(300, 380), -8, true, rng.randf() < 0.5)
	# Ground cover: bushes, ferns, rocks and logs, avoiding gameplay pickups.
	for segment in ground_segments():
		var x: float = segment[0] + 50
		while x < segment[1] - 50:
			var pick := rng.randi() % 6
			var foot := Vector2(x, segment[2] + 6)
			match pick:
				0, 1: prop("terrain/fern.png", foot, rng.randf_range(58, 80), -2, true, rng.randf() < 0.5)
				2: prop("terrain/bush.png", foot, rng.randf_range(56, 74), -2, true, rng.randf() < 0.5)
				3: prop("terrain/rocks.png", foot + Vector2(0, 4), rng.randf_range(44, 58), -2, false, rng.randf() < 0.5)
				4: prop("terrain/fern.png", foot + Vector2(0, 18), rng.randf_range(46, 60), 60, true, rng.randf() < 0.5, Color(0.8, 0.86, 0.76))
				5: if rng.randf() < 0.4: prop("terrain/log.png", foot + Vector2(0, 2), 44, -2, false, rng.randf() < 0.5)
			x += rng.randf_range(150, 260)
	# Vines: tiled painted vine hanging from the crown to the climbable bottom.
	for vine in level.vines:
		var y: float = vine[1]
		var vine_tex := tex("terrain/vine.png")
		var s := 0.32
		while y < vine[2] - 10:
			var piece := Sprite2D.new()
			piece.texture = vine_tex
			piece.centered = false
			piece.scale = Vector2(s, s)
			piece.position = Vector2(vine[0] - 130 * s, y - 8 * s)
			piece.z_index = -1
			piece.material = wind_material
			add_child(piece)
			y += 310 * s
	# Framing tree at the start (non-repeating, in front of the playfield edge).
	var frame := Sprite2D.new()
	frame.texture = tex("terrain/foreground-tree-frame.png")
	frame.centered = false
	frame.scale = Vector2.ONE * SCREEN_SCALE
	frame.position = Vector2(-150, 110)
	frame.z_index = 70
	frame.material = wind_material
	add_child(frame)
