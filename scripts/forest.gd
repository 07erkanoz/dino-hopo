extends Node2D
## A scene graph of independent assets, not a camera-locked background picture.
const Art = preload("res://scripts/art.gd")
const Foliage = preload("res://scripts/foliage.gd")
var game: Node2D
var depth_layers: Array[Parallax2D] = []

func _ready() -> void:
	z_index = -20
	for depth in [0.18, 0.46, 0.78]:
		var layer := Parallax2D.new()
		layer.scroll_scale = Vector2(depth, 1)
		add_child(layer)
		depth_layers.append(layer)
	for i in range(-2, 10):
		plant(depth_layers[0], 0, Vector2(i * 580, 590), 450 + posmod(i * 59, 120), Color("adbf83"), 0.003, i)
	for i in range(-1, 7):
		plant(depth_layers[1], 0, Vector2(i * 1050 + 300, 620), 590 + posmod(i * 47, 120), Color("b8c687"), 0.005, i)
	for i in range(-1, 5):
		plant(depth_layers[2], 0, Vector2(i * 1600 - 110, 620), 800 + posmod(i * 31, 90), Color.WHITE, 0.004, i)
	# Foreground flowers sit at each section's actual ground elevation.
	var foreground := Node2D.new()
	foreground.z_as_relative = false
	foreground.z_index = -1
	add_child(foreground)
	for i in range(1, 26):
		var x := float(i * 197 + posmod(i * 37, 90))
		if x > 1080 and x < 1300: continue
		var ground := 536.0 if (x >= 2176 and x < 2944) or (x >= 3712 and x < 4224) else 600.0
		var kind := 5 if i % 3 != 0 else 2
		plant(foreground, kind, Vector2(x, ground + 4), 22 + posmod(i * 11, 14) if kind == 5 else 38 + posmod(i * 11, 18), Color.WHITE, 0.035, i)

func plant(parent: Node, kind: int, foot: Vector2, height: float, tint: Color, wind: float, phase: int) -> void:
	var sprite := Foliage.new()
	sprite.texture = Art.sprite("habitat", posmod(phase, 2)) if parent is Parallax2D else Art.sprite("jungle", kind)
	sprite.offset.y = -sprite.texture.get_height() / 2
	sprite.position = foot
	var factor := height / sprite.texture.get_height()
	sprite.scale = Vector2(factor * (0.82 + posmod(phase, 4) * 0.1), factor)
	if parent is Parallax2D and parent != depth_layers[2]:
		var palette := Shader.new()
		palette.code = "shader_type canvas_item; uniform vec4 dark_color : source_color; uniform vec4 light_color : source_color; void fragment(){ vec4 t=texture(TEXTURE,UV); float l=dot(t.rgb,vec3(0.299,0.587,0.114)); float band=floor(l*4.0)/3.0; COLOR=vec4(mix(dark_color.rgb,light_color.rgb,clamp(band,0.0,1.0)),t.a); }"
		var material := ShaderMaterial.new()
		material.shader = palette
		material.set_shader_parameter("dark_color", Color("427970") if parent == depth_layers[0] else Color("3e6e4b"))
		material.set_shader_parameter("light_color", Color("94b79b") if parent == depth_layers[0] else Color("91b85f"))
		sprite.material = material
	else:
		sprite.modulate = tint
	sprite.phase = phase * 1.7
	sprite.wind = wind
	sprite.flip_h = phase % 2 == 0
	parent.add_child(sprite)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(game.camera): return
	var left: float = game.camera.position.x - 660
	# Color-only atmosphere behind separate parallax objects.
	for i in 12:
		draw_rect(Rect2(left, i * 64 - 20, 1340, 65), Color("ffedb0").lerp(Color("a8cfaa"), i / 12.0))
	var t := Time.get_ticks_msec() / 1000.0
	# River flows through the real terrain gap.
	draw_rect(Rect2(1095, 657, 190, 350), Color("3faca6"))
	for i in 9:
		var x := 1100 + fmod(t * 38 + i * 21, 175)
		draw_line(Vector2(x, 663 + sin(t * 2 + i) * 4), Vector2(x + 18, 663 + sin(t * 2 + i) * 4), Color("c9f7df"), 3)
	# Butterflies use animated wing geometry and independent world positions.
	for i in 12:
		var p := Vector2(220 + i * 397 + sin(t + i) * 24, 270 + sin(t * 0.7 + i * 2) * 70)
		var flap := absf(sin(t * 9 + i)) * 6 + 1
		var color: Color = [Color("e5b951"), Color("ba80c4"), Color("ef9873")][i % 3]
		draw_circle(p - Vector2(flap / 2, 0), flap, color)
		draw_circle(p + Vector2(flap / 2, 0), flap, color)
		draw_line(p - Vector2(0,5), p + Vector2(0,5), Color("5c4933"), 2)
