extends CharacterBody2D
## Enemies. species 0: ceratopsian (ground: patrol -> telegraphed windup ->
## charge -> recover). species 1: pterosaur (hovering patrol -> swoop dive).
## Both are Skeleton2D rigs; club hits stun, recoil and drain health, and the
## last hit plays the death animation before the body fades out.
signal defeated(enemy: CharacterBody2D)
const DinoRig = preload("res://scripts/rig/dino_rig.gd")
const PteroRig = preload("res://scripts/rig/ptero_rig.gd")
const DINO_ART_HEIGHT := 298.0   # head top to sole in art pixels
const RECOIL_TIME := 0.43
var species := 0
var home_x := 0.0
var home_y := 0.0
var direction := -1.0
var stunned := 0.0
var stun_count := 0
var game: Node2D
var body_height := 196.0
var hit_radius := 115.0
var contact_radius := 125.0
var state := "patrol"
var state_left := 0.0
var travelled := 0.0
var gait_phase := 0.0
var walk_frame := 0
var dangerous := false
var desired_direction := -1.0
var hit_pause := 0.0
var recoil_left := 0.0
var recoil_direction := 1.0
var reaction_frame := 0
var flash_left := 0.0
var health := 3
var alive := true
var fade_left := 0.0
var points := 500
var rig: Node2D
var rig_scale := 1.0
var swoop_target := Vector2.ZERO
var time := 0.0

func _ready() -> void:
	home_x = position.x
	home_y = position.y
	collision_layer = 4
	var collision := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	if species == 0:
		collision_mask = 1
		box.size = Vector2(230, 150)
		rig = DinoRig.new()
		rig_scale = body_height / DINO_ART_HEIGHT
		health = 3
		points = 800
	else:
		collision_mask = 0
		body_height = 140
		hit_radius = 58
		contact_radius = 64
		box.size = Vector2(62, 68)
		rig = PteroRig.new()
		rig_scale = 0.42
		health = 2
		points = 600
		state = "fly"
	collision.shape = box
	collision.position.y = -box.size.y / 2
	add_child(collision)
	add_child(rig)
	update_rig()

func stun() -> void:
	stunned = 2.7 if species == 0 else 1.2
	stun_count += 1
	state = "stunned"
	state_left = stunned
	dangerous = false
	queue_redraw()

func receive_hit(from: Vector2, strength: float = 1.0) -> void:
	if not alive: return
	stun()
	recoil_direction = 1.0 if global_position.x >= from.x else -1.0
	recoil_left = RECOIL_TIME
	hit_pause = 0.055
	flash_left = 0.075
	reaction_frame = 0
	velocity.x = recoil_direction * 220 * strength
	if species == 0 and is_on_floor(): velocity.y = -95 * strength
	health -= 1
	if health <= 0:
		alive = false
		state = "dead"
		dangerous = false
		fade_left = 2.2
		collision_layer = 0
		defeated.emit(self)
		rig.travel("die", true)
	else:
		rig.travel("hurt", true)

func hit_center() -> Vector2:
	if species == 1: return global_position
	return global_position - Vector2(0, body_height * 0.43)

func enter_turn(new_direction: float) -> void:
	state = "turn"
	state_left = 0.18
	desired_direction = new_direction

func nearest_hero(reach: float, vertical: float) -> CharacterBody2D:
	var hero: CharacterBody2D
	if not is_instance_valid(game): return hero
	var nearest := reach
	for candidate in game.players:
		if candidate.dead: continue
		var distance := absf(candidate.position.x - position.x)
		if distance < nearest and absf(candidate.position.y - position.y) < vertical:
			nearest = distance
			hero = candidate
	return hero

func _physics_process(delta: float) -> void:
	time += delta
	flash_left = maxf(0, flash_left - delta)
	if hit_pause > 0:
		hit_pause = maxf(0, hit_pause - delta)
		update_rig()
		return
	if not alive:
		fade_left = maxf(0.0, fade_left - delta)
		velocity.x = move_toward(velocity.x, 0, 500 * delta)
		if species == 0 or not is_on_floor_like():
			velocity.y = minf(velocity.y + 1700 * delta, 1000)
		if species == 1:
			position += velocity * delta
			if position.y > ground_below(): position.y = ground_below()
		else:
			move_and_slide()
		if fade_left < 0.6: rig.modulate.a = fade_left / 0.6
		if fade_left <= 0.0: visible = false
		update_rig()
		return
	if recoil_left > 0:
		recoil_left = maxf(0, recoil_left - delta)
		var elapsed := RECOIL_TIME - recoil_left
		reaction_frame = 0 if elapsed < 0.07 else (1 if elapsed < 0.18 else (2 if elapsed < 0.32 else 3))
		velocity.x = move_toward(velocity.x, 0, 580 * delta)
		if species == 0:
			velocity.y = minf(velocity.y + 1700 * delta, 1000)
			move_and_slide()
		else:
			velocity.y = move_toward(velocity.y, 0, 600 * delta)
			position += velocity * delta
		update_rig()
		return
	if species == 0: ground_behaviour(delta)
	else: flying_behaviour(delta)
	update_rig()

func ground_behaviour(delta: float) -> void:
	var old_x := position.x
	stunned = maxf(0, stunned - delta)
	state_left = maxf(0, state_left - delta)
	var hero := nearest_hero(480.0, 150.0)
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
		var probe_x := position.x + signf(velocity.x) * 105
		var ray := PhysicsRayQueryParameters2D.create(Vector2(probe_x, position.y - 10), Vector2(probe_x, position.y + 48), 1)
		if get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			velocity.x = 0
			enter_turn(-direction)
	velocity.y = minf(velocity.y + delta * 1700, 1000)
	move_and_slide()
	var moved := absf(position.x - old_x)
	travelled += moved
	var stride: float = (DinoRig.CHARGE_STRIDE if state == "charge" else DinoRig.STRIDE) * rig_scale
	gait_phase = fposmod(gait_phase + moved / stride, 1.0)
	walk_frame = int(gait_phase * 8.0) % 8

func flying_behaviour(delta: float) -> void:
	stunned = maxf(0, stunned - delta)
	state_left = maxf(0, state_left - delta)
	var hero := nearest_hero(320.0, 420.0)
	if stunned > 0:
		state = "stunned"
	elif state == "stunned":
		state = "fly"
		state_left = 0.8
	if state == "fly":
		var target := Vector2(home_x + sin(time * 0.7) * 170.0, home_y + sin(time * 1.9) * 18.0)
		velocity = velocity.lerp((target - position) * 2.2, minf(1.0, delta * 3.0))
		if absf(velocity.x) > 8: direction = signf(velocity.x)
		if is_instance_valid(hero) and state_left <= 0 and hero.position.y > position.y + 40:
			state = "swoop"
			state_left = 1.1
			swoop_target = hero.position + Vector2(0, -40)
			direction = signf(swoop_target.x - position.x) if swoop_target.x != position.x else direction
	elif state == "swoop":
		var to_target := swoop_target - position
		if state_left > 0.45 and to_target.length() > 20:
			velocity = velocity.move_toward(to_target.normalized() * 360.0, 1400.0 * delta)
		else:
			velocity = velocity.move_toward(Vector2(direction * 160.0, -260.0), 900.0 * delta)
		if state_left <= 0 or position.y < home_y - 10 and state_left < 0.3:
			state = "fly"
			state_left = 1.6
	elif state == "stunned":
		velocity = velocity.move_toward(Vector2.ZERO, 600 * delta)
	dangerous = state == "swoop" or state == "fly"
	var old := position
	position += velocity * delta
	position.y = minf(position.y, ground_below() - 30.0)
	var moved := position.distance_to(old)
	travelled += moved
	walk_frame = int(fposmod(travelled / 100.0, 1.0) * 8.0)

func is_on_floor_like() -> bool:
	return position.y >= ground_below() - 1.0

## Terrain height under a flyer (for falling bodies and not diving into soil).
func ground_below() -> float:
	if not is_inside_tree(): return 600.0
	var ray := PhysicsRayQueryParameters2D.create(Vector2(position.x, position.y - 20), Vector2(position.x, 1200), 1)
	var hit := get_world_2d().direct_space_state.intersect_ray(ray)
	return 1100.0 if hit.is_empty() else hit.position.y

func animation_state() -> String:
	if not alive: return "die"
	if recoil_left > 0: return "hurt"
	if species == 1:
		return "swoop" if state == "swoop" else "fly"
	match state:
		"windup": return "windup"
		"charge": return "charge"
		"stunned", "recover", "turn": return "idle"
	return "walk" if absf(velocity.x) > 3 else "idle"

func update_rig() -> void:
	if not is_instance_valid(rig) or rig.tree == null: return
	var face := -direction if absf(direction) > 0 else 1.0
	var bob := 1.0
	if species == 0 and state == "windup": bob = 1.0 + 0.04 * sin(time * 30.0)
	rig.scale = Vector2(rig_scale * face, rig_scale * bob)
	if species == 1 and alive:
		rig.rotation = clampf(velocity.y / 900.0, -0.35, 0.45) * face * -1.0 if state == "swoop" else 0.0
	var flash := flash_left / 0.075
	rig.modulate = Color(1.0 + flash, 1.0 + flash, 1.0 + flash * 0.7, rig.modulate.a)
	if species == 0: rig.set_cycle_phase(gait_phase)
	var want := animation_state()
	if want != "hurt" and want != "die": rig.travel(want)
	queue_redraw()

func _draw() -> void:
	if not alive and fade_left <= 0: return
	if species == 0:
		var shadow := PackedVector2Array()
		for i in 24: shadow.append(Vector2(cos(i * TAU / 24) * body_height * 0.6, sin(i * TAU / 24) * 9))
		draw_colored_polygon(shadow, Color(0.2,0.16,0.1,0.17))
	if state == "windup":
		draw_string(ThemeDB.fallback_font, Vector2(-5, -body_height - 10), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color("c45d35"))
	if stunned > 0 and alive:
		for i in 3:
			var theta := time * 3.3 + i * TAU / 3
			var center := Vector2(cos(theta) * 37, -body_height * (0.95 if species == 0 else 0.5) + sin(theta) * 9)
			draw_circle(center, 6, Color("ffe27a"))
			draw_circle(center, 3, Color("fff8d8"))
