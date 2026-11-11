extends CharacterBody2D
const Art = preload("res://scripts/art.gd")
var species := 0
var home_x := 0.0
var direction := -1.0
var stunned := 0.0
var stun_count := 0
var game: Node2D
var body_height := 208.0
var hit_radius := 115.0
var contact_radius := 125.0
var state := "patrol"
var state_left := 0.0
var travelled := 0.0
var walk_frame := 0
var dangerous := false
var desired_direction := -1.0

func _ready() -> void:
	home_x = position.x
	if species != 0:
		body_height = 140
		hit_radius = 58
		contact_radius = 64
	collision_layer = 4
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(230, 150) if species == 0 else Vector2(62, 68)
	collision.shape = box
	collision.position.y = -box.size.y / 2
	add_child(collision)

func stun() -> void:
	stunned = 2.7
	stun_count += 1
	state = "stunned"
	state_left = stunned
	dangerous = false
	queue_redraw()

func hit_center() -> Vector2:
	return global_position - Vector2(0, body_height * 0.43)

func enter_turn(new_direction: float) -> void:
	state = "turn"
	state_left = 0.18
	desired_direction = new_direction

func _physics_process(delta: float) -> void:
	var old_x := position.x
	stunned = maxf(0, stunned - delta)
	state_left = maxf(0, state_left - delta)
	var hero: CharacterBody2D
	if is_instance_valid(game):
		var nearest := 480.0
		for candidate in game.players:
			var distance := absf(candidate.position.x - position.x)
			if distance < nearest and absf(candidate.position.y - position.y) < 150:
				nearest = distance
				hero = candidate
	if stunned > 0:
		state = "stunned"
	elif state == "stunned":
		state = "recover"
		state_left = 0.65
	elif state == "turn" and state_left <= 0:
		direction = desired_direction
		state = "patrol"
	elif state == "windup" and state_left <= 0:
		state = "charge"
		state_left = 0.75
	elif state == "charge" and (state_left <= 0 or is_on_wall()):
		state = "recover"
		state_left = 0.85
	elif state == "recover" and state_left <= 0:
		state = "patrol"
	elif state == "patrol":
		if is_instance_valid(hero) and absf(hero.position.x - position.x) < 360:
			direction = signf(hero.position.x - position.x)
			if direction == 0: direction = -1
			state = "windup"
			state_left = 0.7
		elif (absf(position.x - home_x) > 190 and (position.x - home_x) * direction > 0) or is_on_wall():
			enter_turn(-direction)
	var target_speed := 0.0
	if state == "patrol": target_speed = direction * 70
	if state == "charge": target_speed = direction * 255
	dangerous = state == "charge"
	velocity.x = move_toward(velocity.x, target_speed, delta * (600 if state == "charge" else 1000))
	if is_on_floor() and absf(velocity.x) > 1:
		var probe_x := position.x + signf(velocity.x) * (105 if species == 0 else 52)
		var ray := PhysicsRayQueryParameters2D.create(Vector2(probe_x, position.y - 10), Vector2(probe_x, position.y + 48), 1)
		if get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			velocity.x = 0
			enter_turn(-direction)
	velocity.y = minf(velocity.y + delta * 1700, 1000)
	move_and_slide()
	travelled += absf(position.x - old_x)
	walk_frame = int(fmod(travelled / 100.0, 1.0) * 8)
	queue_redraw()

func _draw() -> void:
	var shadow := PackedVector2Array()
	for i in 24: shadow.append(Vector2(cos(i * TAU / 24) * body_height * 0.65, sin(i * TAU / 24) * 9))
	draw_colored_polygon(shadow, Color(0.2,0.16,0.1,0.17))
	var lean := 0.035 if state == "windup" else 0.0
	draw_set_transform(Vector2.ZERO, lean * direction, Vector2(-direction, 1))
	if species == 0:
		var frame := walk_frame if absf(velocity.x) > 3 else 0
		var image := Art.sprite("ceratopsian_motion", frame)
		var sheet: Dictionary = Art.data.ceratopsian_motion
		var factor := body_height / float(sheet.reference_height)
		var origin := Vector2(sheet.root_x, sheet.ground) * factor
		draw_texture_rect(image, Rect2(-origin, image.get_size() * factor), false)
	else:
		var image := Art.sprite("creatures", species)
		var size := image.get_size() * (body_height / image.get_height())
		draw_texture_rect(image, Rect2(Vector2(-size.x / 2, -size.y), size), false)
	draw_set_transform(Vector2.ZERO)
	if state == "windup":
		draw_string(ThemeDB.fallback_font, Vector2(-5, -body_height-10), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("c45d35"))
	if stunned > 0:
		for i in 3:
			var theta := Time.get_ticks_msec() / 300.0 + i * TAU / 3
			var center := Vector2(cos(theta) * 37, -body_height + sin(theta) * 9)
			draw_texture_rect(Art.sprite("equipment", 3), Rect2(center - Vector2(11,11), Vector2(22,22)), false)
