extends CharacterBody2D
## Hero controller. Movement values are exported so they can be tuned in the
## inspector. Çağan (hero 0) is drawn by a Skeleton2D rig driven by an
## AnimationTree; the other approved heroes keep their pose drawings.
signal club_hit(hero: CharacterBody2D)
signal throw_requested(hero: CharacterBody2D)
signal died(hero: CharacterBody2D)
signal fell(hero: CharacterBody2D)
const Art = preload("res://scripts/art.gd")
const Roster = preload("res://scripts/roster.gd")
const Feedback = preload("res://scripts/hit_feedback.gd")
const CaganRig = preload("res://scripts/rig/cagan_rig.gd")
## 8 gameplay phases of the club swing; frames 3-4 are the hit window.
const ATTACK_DURATIONS := [0.04, 0.08, 0.08, 0.055, 0.075, 0.08, 0.08, 0.07]
const ATTACK_TOTAL := 0.58
const MAX_HEALTH := 3

@export_group("Ground")
@export var walk_speed := 150.0
@export var run_speed := 320.0
## Seconds of continuous ground movement before the hero breaks into a run.
@export var run_after := 0.4
@export var ground_accel := 1500.0
@export var ground_decel := 1900.0
@export var turn_accel := 2600.0
@export_group("Air")
@export var air_accel := 950.0
@export var air_decel := 320.0
@export var gravity := 1750.0
@export var fall_gravity_scale := 1.2
@export var max_fall_speed := 1100.0
@export_group("Jump")
@export var jump_velocity := 730.0
## Upward speed multiplier when jump is released early (short hop).
@export var jump_cut := 0.45
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.12
## Floor snap distance: small steps/ledges are landed on instead of skipped.
@export var landing_snap := 14.0
## Head-bump forgiveness: nudge sideways around ceiling corners (pixels).
@export var corner_correction := 10.0
@export var landing_time := 0.12
@export_group("Feel")
@export var squash_strength := 0.22
@export var lean_degrees := 7.0

var slot := 0
var hero_index := 0
var language := "tr"
var input_prefix := ""
var world_width := 5120.0
var kill_y := 950.0
var touch_axis := 0.0
var touch_jump := false
var touch_club := false
var touch_throw := false
var checkpoint := Vector2.ZERO
var coyote_left := 0.0
var jump_buffer := 0.0
var jumping := false
var facing := 1.0
var vines: Array = []
var climbing := false
var has_boomerang := false
var boomerang_active := false
var swing_left := 0.0
var club_cooldown := 0.0
var attack_connected := false
var _was_jump := false
var _was_club := false
var _was_throw := false
var grace := 1.4
var moving_time := 0.0
var run_distance := 0.0
var gait_phase := 0.0
var run_frame := 0
var landing_left := 0.0
var hurt_left := 0.0
var dead := false
var dead_left := 0.0
var health := MAX_HEALTH
var motion_state := "idle"
var attack_frame := 0
var attack_targets: Dictionary = {}
var attack_number := 0
var attack_facing := 1.0
var previous_club_tip := Vector2.ZERO
var hit_pause := 0.0
var swing_sound_played := false
var sfx_enabled := true
var name_tag: Label
var rig: Node2D
var squash := Vector2.ONE
var squash_velocity := Vector2.ZERO
var lean := 0.0
var lean_velocity := 0.0
var head_lag := 0.0
var head_lag_velocity := 0.0
var _last_vx := 0.0

func _ready() -> void:
	floor_snap_length = landing_snap
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 19.0
	capsule.height = 88.0
	shape.shape = capsule
	shape.position.y = -44.0
	add_child(shape)
	if hero_index == 0:
		rig = CaganRig.new()
		rig.scale = Vector2.ONE * CaganRig.ART_SCALE
		add_child(rig)
	name_tag = Label.new()
	name_tag.position = Vector2(-65, -152)
	name_tag.size.x = 130
	name_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_tag.add_theme_font_size_override("font_size", 16)
	name_tag.add_theme_color_override("font_color", Color("fff7dc"))
	name_tag.add_theme_color_override("font_outline_color", Color("493126"))
	name_tag.add_theme_constant_override("outline_size", 6)
	name_tag.visible = input_prefix != ""
	add_child(name_tag)
	refresh_tag()

func refresh_tag() -> void:
	if is_instance_valid(name_tag):
		name_tag.text = "P%d · %s" % [slot + 1, Roster.hero_name(hero_index, language)]

func act(action: String) -> StringName:
	return StringName(input_prefix + action)

func read_axis() -> float:
	var axis := Input.get_axis(act("move_left"), act("move_right"))
	if slot == 0 and touch_axis != 0.0: axis = touch_axis
	return axis

func _physics_process(delta: float) -> void:
	if hit_pause > 0:
		hit_pause = maxf(0, hit_pause - delta)
		queue_redraw()
		return
	if dead:
		dead_left = maxf(0.0, dead_left - delta)
		velocity.x = move_toward(velocity.x, 0.0, ground_decel * delta)
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		move_and_slide()
		update_animation(delta, 0.0)
		return
	var previous_position := position
	var was_grounded := is_on_floor()
	var incoming_y := velocity.y
	landing_left = maxf(0, landing_left - delta)
	hurt_left = maxf(0, hurt_left - delta)
	grace = maxf(0.0, grace - delta)
	var axis := read_axis()
	var vertical := Input.get_axis(act("move_up"), act("move_down"))
	var jump_held := Input.is_action_pressed(act("jump")) or (slot == 0 and touch_jump)
	var jump_pressed := jump_held and not _was_jump
	_was_jump = jump_held
	var can_climb := false
	for vine in vines:
		if absf(position.x - vine[0]) < 30 and position.y > vine[1] and position.y < vine[2] + 12:
			can_climb = true
	if slot == 0 and touch_jump and can_climb and not climbing: vertical = -1.0
	var dismount := climbing and jump_pressed and absf(axis) > 0.1
	climbing = can_climb and not dismount and (absf(vertical) > 0.1 or (climbing and not jump_pressed))
	# Coyote time and jump buffer.
	if was_grounded:
		coyote_left = coyote_time
		jumping = false
	else:
		coyote_left = maxf(0.0, coyote_left - delta)
	if jump_pressed: jump_buffer = jump_buffer_time
	else: jump_buffer = maxf(0.0, jump_buffer - delta)
	if climbing:
		velocity.y = vertical * 170.0
		velocity.x = move_toward(velocity.x, 0.0, ground_decel * delta)
		jump_buffer = 0.0
		if absf(vertical) < 0.1 and slot == 0 and touch_jump: velocity.y = -170.0
	elif dismount:
		velocity.y = -jump_velocity * 0.6
		velocity.x = signf(axis) * walk_speed
		jumping = true
	elif jump_buffer > 0.0 and coyote_left > 0.0 and hurt_left <= 0.0:
		launch()
	if not climbing:
		# Variable height: releasing jump early cuts the rise once.
		if jumping and not jump_held and velocity.y < 0.0:
			velocity.y *= jump_cut
			jumping = false
		var g := gravity * (fall_gravity_scale if velocity.y > 0.0 else 1.0)
		velocity.y = minf(velocity.y + g * delta, max_fall_speed)
	if hurt_left <= 0 and not climbing:
		var grounded := was_grounded
		if absf(axis) < 0.1: moving_time = 0.0
		elif grounded: moving_time += delta
		var top_speed := run_speed if moving_time >= run_after else walk_speed
		var target := axis * top_speed
		var rate: float
		if absf(axis) < 0.1: rate = ground_decel if grounded else air_decel
		elif velocity.x * axis < 0.0: rate = turn_accel if grounded else air_accel
		else: rate = ground_accel if grounded else air_accel
		if swing_left > 0 and grounded:
			target = 0.0
			rate = 2800.0
		velocity.x = move_toward(velocity.x, target, rate * delta)
		if swing_left <= 0 and absf(axis) > 0.1 and (absf(velocity.x) < 35 or velocity.x * axis > 0): facing = signf(axis)
	if climbing and position.y < 170 and velocity.y < 0: velocity.y = 0
	correct_corner(delta)
	move_and_slide()
	if is_on_floor() and not was_grounded and incoming_y > 140:
		landing_left = landing_time
		var impact := clampf(incoming_y / 900.0, 0.3, 1.0)
		squash_velocity += Vector2(3.5, -4.5) * impact * squash_strength * 10.0
	var moved := absf(position.x - previous_position.x)
	if is_on_floor() and moved > 0.05:
		run_distance += moved
	position.x = clampf(position.x, 28.0, world_width - 35)
	if position.y > kill_y:
		respawn()
		fell.emit(self)
	club_cooldown = maxf(0.0, club_cooldown - delta)
	swing_left = maxf(0.0, swing_left - delta)
	var club := Input.is_action_pressed(act("attack")) or (slot == 0 and touch_club)
	var throwing := Input.is_action_pressed(act("throw")) or (slot == 0 and touch_throw)
	if club and not _was_club: begin_swing()
	if swing_left > 0:
		attack_frame = attack_frame_at(ATTACK_TOTAL - swing_left)
		if attack_frame >= 2 and not swing_sound_played:
			swing_sound_played = true
			if sfx_enabled: Feedback.play_sound(self, "swing", 1.0, -14)
		if attack_frame == 3 or attack_frame == 4:
			club_hit.emit(self)
		previous_club_tip = club_tip()
	if throwing and not _was_throw: throw_requested.emit(self)
	_was_club = club
	_was_throw = throwing
	update_animation(delta, moved if is_on_floor() else 0.0)

func launch() -> void:
	velocity.y = -jump_velocity
	coyote_left = 0.0
	jump_buffer = 0.0
	jumping = true
	landing_left = 0.0
	squash_velocity += Vector2(-3.0, 4.0) * squash_strength * 10.0

## Nudge around ceiling corners so a jump that clips a ledge edge still clears.
func correct_corner(delta: float) -> void:
	if velocity.y >= 0.0 or corner_correction <= 0.0: return
	var motion := Vector2(0, velocity.y * delta)
	if not test_move(global_transform, motion): return
	for step in range(1, int(corner_correction) + 1):
		for dir in [1.0, -1.0]:
			var offset := Vector2(dir * step, 0)
			if not test_move(global_transform.translated(offset), motion):
				position += offset
				return

func update_animation(delta: float, moved: float) -> void:
	var state := "idle"
	if dead: state = "die"
	elif hurt_left > 0: state = "hurt"
	elif swing_left > 0: state = "attack"
	elif climbing: state = "climb"
	elif not is_on_floor(): state = "jump" if velocity.y < 0 else "fall"
	elif landing_left > 0: state = "land"
	elif absf(velocity.x) > (walk_speed + run_speed) * 0.5: state = "run"
	elif absf(velocity.x) > 12: state = "walk"
	motion_state = state
	# Distance-driven gait: one cycle covers exactly one stride, so the planted
	# foot stays put on the ground (no foot sliding at any speed).
	var stride_px := (CaganRig.RUN_STRIDE if state == "run" else CaganRig.WALK_STRIDE) * CaganRig.ART_SCALE
	gait_phase = fposmod(gait_phase + moved / stride_px, 1.0)
	run_frame = int(gait_phase * 8.0) % 8
	# Weight: squash/stretch spring, lean into acceleration, head follow-through.
	var accel := (velocity.x - _last_vx) / maxf(delta, 0.001)
	_last_vx = velocity.x
	squash_velocity += (Vector2.ONE - squash) * 260.0 * delta
	squash_velocity *= exp(-14.0 * delta)
	squash += squash_velocity * delta
	squash = squash.clamp(Vector2(0.7, 0.7), Vector2(1.35, 1.35))
	var lean_target := clampf(velocity.x / run_speed, -1.0, 1.0) * lean_degrees * facing if is_on_floor() and state in ["walk", "run"] else 0.0
	lean_target += clampf(-accel / 4000.0, -1.0, 1.0) * 4.0 * facing
	lean_velocity += (lean_target - lean) * 160.0 * delta
	lean_velocity *= exp(-12.0 * delta)
	lean += lean_velocity * delta
	head_lag_velocity += (-clampf(accel / 3000.0, -1.0, 1.0) * 6.0 * facing - head_lag) * 200.0 * delta - velocity.y / 2000.0
	head_lag_velocity *= exp(-10.0 * delta)
	head_lag = clampf(head_lag + head_lag_velocity * delta, -10.0, 10.0)
	if is_instance_valid(rig):
		var s: float = CaganRig.ART_SCALE
		var face := attack_facing if swing_left > 0 else facing
		rig.scale = Vector2(s * squash.x * face, s * squash.y)
		rig.rotation = deg_to_rad(lean) * face
		rig.parts["head"].rotation = deg_to_rad(head_lag)
		rig.set_cycle_phase(gait_phase)
		rig.travel(state, state == "attack" and rig.current_state() != "attack")
		var flicker := grace > 0.0 and not dead and int(grace * 12.0) % 2 == 0 and grace < 1.3
		rig.modulate.a = 0.45 if flicker else 1.0
	queue_redraw()

func begin_swing() -> void:
	if club_cooldown > 0 or dead: return
	club_cooldown = ATTACK_TOTAL + 0.04
	swing_left = ATTACK_TOTAL
	attack_connected = false
	attack_frame = 0
	attack_targets.clear()
	attack_number += 1
	attack_facing = facing
	swing_sound_played = false
	if is_instance_valid(rig): rig.travel("attack", true)
	previous_club_tip = club_tip()

func attack_frame_at(elapsed: float) -> int:
	var cursor := 0.0
	for i in ATTACK_DURATIONS.size():
		cursor += ATTACK_DURATIONS[i]
		if elapsed < cursor: return i
	return 7

## Club head in world space. The rig answers from its real bone transforms;
## pose-drawing heroes use the measured club positions of their attack frames.
func club_tip() -> Vector2:
	if is_instance_valid(rig) and swing_left > 0 and attack_frame >= 3:
		return rig.club_tip_global()
	var local := Vector2(56, -73) if attack_frame == 3 else Vector2(55, -16)
	if attack_frame < 3: local = Vector2(-35, -90)
	return global_position + Vector2(local.x * attack_facing, local.y)

func respawn() -> void:
	position = checkpoint
	velocity = Vector2.ZERO
	climbing = false
	grace = 1.4
	health = MAX_HEALTH
	hurt_left = 0
	dead = false
	swing_left = 0
	jumping = false
	if is_instance_valid(rig): rig.travel("idle", true)
	refresh_tag()

func hurt(from_x: float) -> void:
	if grace > 0 or dead: return
	health -= 1
	if health <= 0:
		die()
		return
	grace = 1.1
	hurt_left = 0.32
	swing_left = 0
	velocity = Vector2(360 if position.x >= from_x else -360, -260)
	if sfx_enabled: Feedback.play_sound(self, "recoil_a", 1.25, -12)

func heal(amount: int) -> void:
	health = mini(MAX_HEALTH, health + amount)

func die() -> void:
	dead = true
	dead_left = 1.4
	health = 0
	swing_left = 0
	climbing = false
	velocity = Vector2(-facing * 120.0, -320.0)
	died.emit(self)

func _draw() -> void:
	if is_on_floor() and not dead:
		var shadow := PackedVector2Array()
		for i in 24: shadow.append(Vector2(cos(i * TAU / 24) * 26, sin(i * TAU / 24) * 5))
		draw_colored_polygon(shadow, Color(0.2, 0.16, 0.1, 0.22))
	if is_instance_valid(rig): return
	# Pose drawings for heroes 02-04 (no skeleton parts exist for them yet).
	var pose := 0
	if not is_on_floor(): pose = 3
	elif absf(velocity.x) > 10: pose = 1 + int(gait_phase * 2.0) % 2
	var face := attack_facing if swing_left > 0 else facing
	draw_set_transform(Vector2.ZERO, 0, Vector2(face * squash.x, squash.y))
	var texture := Art.sprite("heroes", Roster.frame(hero_index, pose))
	var size := texture.get_size() * (128.0 / Art.sprite("heroes", hero_index).get_height())
	draw_texture_rect(texture, Rect2(Vector2(-size.x / 2, -size.y), size), false, Color(1, 1, 1, 0.5 if grace > 0 and int(grace * 12) % 2 == 0 else 1.0))
	var angle := 0.85
	if swing_left > 0: angle = lerpf(-1.5, 1.1, 1.0 - swing_left / ATTACK_TOTAL)
	var anchor := Vector2(29, -51) if pose == 0 else Vector2(40, -64)
	draw_set_transform(Vector2(anchor.x * face, anchor.y), angle * face, Vector2(face, 1))
	var club := Art.sprite("equipment", 0)
	var club_size := club.get_size() * (64.0 / club.get_height())
	draw_texture_rect(club, Rect2(Vector2(-club_size.x / 2, -club_size.y + 7), club_size), false)
	draw_set_transform(Vector2.ZERO)
