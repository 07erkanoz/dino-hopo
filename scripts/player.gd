extends CharacterBody2D
signal club_hit(hero: CharacterBody2D)
signal throw_requested(hero: CharacterBody2D)
const Art = preload("res://scripts/art.gd")
const Roster = preload("res://scripts/roster.gd")
const Feedback = preload("res://scripts/hit_feedback.gd")
const ATTACK_DURATIONS := [0.04, 0.08, 0.08, 0.055, 0.075, 0.08, 0.08, 0.07]
const ATTACK_TOTAL := 0.58
var slot := 0
var hero_index := 0
var language := "tr"
var world_width := 5120.0
var touch_axis := 0.0
var touch_jump := false
var touch_club := false
var touch_throw := false
var checkpoint := Vector2.ZERO
var coyote := 0.0
var jump_buffer := 0.0
var facing := 1.0
var vines: Array = []
var climbing := false
var has_boomerang := false
var boomerang_active := false
var swing_left := 0.0
var club_cooldown := 0.0
var attack_connected := false
var _was_jumping := false
var _was_club := false
var _was_throw := false
var grace := 1.4
var run_distance := 0.0
var run_frame := 0
var landing_left := 0.0
var takeoff_left := 0.0
var jump_windup := 0.0
var launch_pending := false
var hurt_left := 0.0
var health := 3
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

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 19.0
	capsule.height = 88.0
	shape.shape = capsule
	shape.position.y = -44.0
	add_child(shape)
	name_tag = Label.new()
	name_tag.text = "P%d · %s" % [slot + 1, Roster.hero_name(hero_index, language)]
	name_tag.position = Vector2(-65, -152)
	name_tag.size.x = 130
	name_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_tag.add_theme_font_size_override("font_size", 16)
	name_tag.add_theme_color_override("font_color", Color("fff7dc"))
	name_tag.add_theme_color_override("font_outline_color", Color("493126"))
	name_tag.add_theme_constant_override("outline_size", 6)
	add_child(name_tag)

func _physics_process(delta: float) -> void:
	if hit_pause > 0:
		hit_pause = maxf(0, hit_pause - delta)
		queue_redraw()
		return
	var previous_position := position
	var was_grounded := is_on_floor()
	var incoming_y := velocity.y
	landing_left = maxf(0, landing_left - delta)
	takeoff_left = maxf(0, takeoff_left - delta)
	jump_windup = maxf(0, jump_windup - delta)
	hurt_left = maxf(0, hurt_left - delta)
	grace = maxf(0.0, grace - delta)
	var left := KEY_A if slot == 0 else KEY_LEFT
	var right := KEY_D if slot == 0 else KEY_RIGHT
	var up := KEY_W if slot == 0 else KEY_UP
	var down := KEY_S if slot == 0 else KEY_DOWN
	var axis := float(Input.is_physical_key_pressed(right)) - float(Input.is_physical_key_pressed(left))
	var vertical := float(Input.is_physical_key_pressed(down)) - float(Input.is_physical_key_pressed(up))
	if slot == 0 and touch_axis != 0.0: axis = touch_axis
	if slot in Input.get_connected_joypads():
		var stick := Input.get_joy_axis(slot, JOY_AXIS_LEFT_X)
		if absf(stick) > 0.2: axis = stick
		var vertical_stick := Input.get_joy_axis(slot, JOY_AXIS_LEFT_Y)
		if absf(vertical_stick) > 0.2: vertical = vertical_stick
	var jumping := Input.is_physical_key_pressed(up) or Input.is_joy_button_pressed(slot, JOY_BUTTON_A)
	var dismount := Input.is_physical_key_pressed(KEY_SPACE if slot == 0 else KEY_SHIFT)
	jumping = jumping or dismount
	if slot == 0: jumping = jumping or touch_jump
	var can_climb := false
	for vine in vines:
		if absf(position.x - vine[0]) < 30 and position.y > vine[1] and position.y < vine[2] + 12:
			can_climb = true
	if slot == 0 and touch_jump and can_climb: vertical = -1.0
	climbing = can_climb and absf(vertical) > 0.1 and not dismount
	if jumping and not _was_jumping: jump_buffer = 0.13
	_was_jumping = jumping
	jump_buffer = maxf(0.0, jump_buffer - delta)
	coyote = 0.12 if is_on_floor() else maxf(0.0, coyote - delta)
	if climbing:
		velocity.y = vertical * 170.0
		jump_buffer = 0.0
	elif dismount and can_climb:
		velocity.y = -400
		velocity.x = (axis if axis != 0 else facing) * 260
	elif not launch_pending and jump_buffer > 0.0 and coyote > 0.0:
		launch_pending = true
		jump_windup = 0.045
		jump_buffer = 0.0
	if launch_pending and jump_windup <= 0.0:
		velocity.y = -720.0
		coyote = 0.0
		launch_pending = false
		takeoff_left = 0.065
	if not climbing:
		if not jumping and not dismount and velocity.y < -240.0:
			velocity.y += 2000.0 * delta
		velocity.y = minf(velocity.y + 1700.0 * delta, 1100.0)
	if hurt_left <= 0:
		var rate := 950.0 if was_grounded else 650.0
		var target_speed := axis * 300.0
		if swing_left > 0 and was_grounded:
			target_speed = 0
			rate = 2800.0
		if axis == 0: rate = 1800.0 if was_grounded else 280.0
		if axis * velocity.x < 0 and absf(velocity.x) > 35:
			target_speed = 0.0
			rate = 2100.0
		velocity.x = move_toward(velocity.x, target_speed, rate * delta)
		if swing_left <= 0 and axis != 0 and (absf(velocity.x) < 35 or velocity.x * axis > 0): facing = signf(axis)
	if climbing and position.y < 170 and velocity.y < 0: velocity.y = 0
	move_and_slide()
	if is_on_floor() and not was_grounded and incoming_y > 140:
		landing_left = 0.13
	if is_on_floor() and absf(position.x - previous_position.x) > 0.05:
		run_distance += absf(position.x - previous_position.x)
		run_frame = int(fmod(run_distance / 144.0, 1.0) * 8)
	motion_state = "climb" if climbing else ("jump" if not is_on_floor() else ("run" if absf(velocity.x) > 12 else "idle"))
	if landing_left > 0: motion_state = "land"
	if launch_pending: motion_state = "anticipate"
	position.x = clampf(position.x, 28.0, world_width - 35)
	if position.y > 950.0: respawn()
	club_cooldown = maxf(0.0, club_cooldown - delta)
	swing_left = maxf(0.0, swing_left - delta)
	var club := Input.is_physical_key_pressed(KEY_F if slot == 0 else KEY_K) or Input.is_joy_button_pressed(slot, JOY_BUTTON_X) or (slot == 0 and touch_club)
	var throwing := Input.is_physical_key_pressed(KEY_G if slot == 0 else KEY_L) or Input.is_joy_button_pressed(slot, JOY_BUTTON_Y) or (slot == 0 and touch_throw)
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
	queue_redraw()

func begin_swing() -> void:
	if club_cooldown > 0: return
	club_cooldown = ATTACK_TOTAL + 0.04
	swing_left = ATTACK_TOTAL
	attack_connected = false
	attack_frame = 0
	attack_targets.clear()
	attack_number += 1
	attack_facing = facing
	swing_sound_played = false
	previous_club_tip = club_tip()

func attack_frame_at(elapsed: float) -> int:
	var cursor := 0.0
	for i in ATTACK_DURATIONS.size():
		cursor += ATTACK_DURATIONS[i]
		if elapsed < cursor: return i
	return 7

func club_tip() -> Vector2:
	# In source frame3 the club head is x~379,y~237; frame4 follows down.
	var local := Vector2(56, -73) if attack_frame == 3 else Vector2(55, -16)
	if attack_frame < 3: local = Vector2(-35, -90)
	return global_position + Vector2(local.x * attack_facing, local.y)

func respawn() -> void:
	position = checkpoint
	velocity = Vector2.ZERO
	climbing = false
	grace = 1.4
	health = 3
	launch_pending = false
	jump_windup = 0
	hurt_left = 0
	if is_instance_valid(name_tag): name_tag.text = "P%d · %s" % [slot + 1, Roster.hero_name(hero_index, language)]

func hurt(from_x: float) -> void:
	if grace > 0: return
	health -= 1
	if health <= 0:
		respawn()
		return
	grace = 1.1
	hurt_left = 0.2
	velocity = Vector2(360 if position.x >= from_x else -360, -260)
	name_tag.text = "P%d · %s  %d♥" % [slot + 1, Roster.hero_name(hero_index, language), health]

func _draw() -> void:
	# The gait advances with actual travel, not global wall-clock time.
	if is_on_floor():
		var shadow := PackedVector2Array()
		for i in 24: shadow.append(Vector2(cos(i * TAU / 24) * 24, sin(i * TAU / 24) * 4))
		draw_colored_polygon(shadow, Color(0.2, 0.16, 0.1, 0.2))
	if hero_index == 0 and swing_left > 0:
		var texture := Art.sprite("cagan_attack", attack_frame)
		var sheet: Dictionary = Art.data.cagan_attack
		var factor := 128.0 / float(sheet.reference_height)
		var origin := Vector2(sheet.root_x, sheet.ground) * factor
		draw_set_transform(Vector2.ZERO, 0, Vector2(attack_facing, 1))
		if attack_frame == 3 or attack_frame == 4:
			draw_arc(Vector2(-10,-76), 76, -1.3, 0.4, 14, Color(1.0,0.94,0.7,0.35), 5, true)
		draw_texture_rect(texture, Rect2(-origin, texture.get_size() * factor), false)
		draw_set_transform(Vector2.ZERO)
		return
	var pose := 0
	if not is_on_floor(): pose = 3
	elif absf(velocity.x) > 10: pose = 1 + (run_frame / 4)
	var anchor := Vector2(29, -51) if pose == 0 else Vector2(40, -64)
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	var use_motion := hero_index == 0 and (motion_state != "idle" or swing_left > 0)
	if use_motion:
		var frame := run_frame
		if motion_state == "anticipate": frame = 9
		elif motion_state == "land": frame = 11
		elif motion_state == "jump" or motion_state == "climb": frame = 10
		elif motion_state == "idle": frame = 8
		if takeoff_left > 0: frame = 9
		if swing_left > 0: frame = 9 if swing_left > 0.17 else 11
		var texture := Art.sprite("cagan_motion", frame)
		var sheet: Dictionary = Art.data.cagan_motion
		var factor := 128.0 / float(sheet.reference_height)
		var origin := Vector2(sheet.root_x, sheet.ground) * factor
		draw_texture_rect(texture, Rect2(-origin, texture.get_size() * factor), false)
		var anchors := [Vector2(37,-64), Vector2(37,-48), Vector2(35,-62), Vector2(38,-82), Vector2(37,-64), Vector2(37,-48), Vector2(35,-62), Vector2(38,-82), Vector2(29,-51), Vector2(-24,-42), Vector2(48,-64), Vector2(45,-43)]
		anchor = anchors[frame]
	else:
		var texture := Art.sprite("heroes", Roster.frame(hero_index, pose))
		var size := texture.get_size() * (128.0 / Art.sprite("heroes", hero_index).get_height())
		draw_texture_rect(texture, Rect2(Vector2(-size.x / 2, -size.y), size), false)
	var angle := 0.85
	if swing_left > 0: angle = lerpf(-1.5, 1.1, 1.0 - swing_left / ATTACK_TOTAL)
	draw_set_transform(Vector2(anchor.x * facing, anchor.y), angle * facing, Vector2(facing, 1))
	var club := Art.sprite("equipment", 0)
	var club_size := club.get_size() * (64.0 / club.get_height())
	draw_texture_rect(club, Rect2(Vector2(-club_size.x / 2, -club_size.y + 7), club_size), false)
	draw_set_transform(Vector2.ZERO)
