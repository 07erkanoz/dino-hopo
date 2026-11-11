extends CharacterBody2D
signal club_hit(hero: CharacterBody2D)
signal throw_requested(hero: CharacterBody2D)
const Art = preload("res://scripts/art.gd")
const Roster = preload("res://scripts/roster.gd")
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

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 19.0
	capsule.height = 88.0
	shape.shape = capsule
	shape.position.y = -44.0
	add_child(shape)
	var name_tag := Label.new()
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
	elif jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = -720.0
		coyote = 0.0
		jump_buffer = 0.0
	if not climbing:
		if not jumping and not dismount and velocity.y < -240.0:
			velocity.y += 2000.0 * delta
		velocity.y = minf(velocity.y + 1700.0 * delta, 1100.0)
	velocity.x = move_toward(velocity.x, axis * 300.0, 2200.0 * delta)
	if axis != 0.0: facing = signf(axis)
	move_and_slide()
	position.x = clampf(position.x, 28.0, world_width - 35)
	if position.y > 950.0: respawn()
	club_cooldown = maxf(0.0, club_cooldown - delta)
	swing_left = maxf(0.0, swing_left - delta)
	var club := Input.is_physical_key_pressed(KEY_F if slot == 0 else KEY_K) or Input.is_joy_button_pressed(slot, JOY_BUTTON_X) or (slot == 0 and touch_club)
	var throwing := Input.is_physical_key_pressed(KEY_G if slot == 0 else KEY_L) or Input.is_joy_button_pressed(slot, JOY_BUTTON_Y) or (slot == 0 and touch_throw)
	if club and not _was_club: begin_swing()
	if swing_left > 0 and swing_left < 0.16 and not attack_connected:
		attack_connected = true
		club_hit.emit(self)
	if throwing and not _was_throw: throw_requested.emit(self)
	_was_club = club
	_was_throw = throwing
	queue_redraw()

func begin_swing() -> void:
	if club_cooldown > 0: return
	club_cooldown = 0.4
	swing_left = 0.29
	attack_connected = false

func respawn() -> void:
	position = checkpoint
	velocity = Vector2.ZERO
	climbing = false
	grace = 1.4

func _draw() -> void:
	var pose := 0
	if not is_on_floor(): pose = 3
	elif absf(velocity.x) > 10: pose = 1 + (int(Time.get_ticks_msec() / 140) % 2)
	var texture := Art.sprite("heroes", Roster.frame(hero_index, pose))
	var idle_height := Art.sprite("heroes", hero_index).get_height()
	var size := texture.get_size() * (128.0 / idle_height)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	draw_texture_rect(texture, Rect2(Vector2(-size.x / 2, -size.y), size), false)
	var anchor := Vector2(29, -51) if pose == 0 else Vector2(40, -64)
	var angle := 0.85
	if swing_left > 0: angle = lerpf(-1.5, 1.1, 1.0 - swing_left / 0.29)
	draw_set_transform(Vector2(anchor.x * facing, anchor.y), angle * facing, Vector2(facing, 1))
	var club := Art.sprite("equipment", 0)
	var club_size := club.get_size() * (64.0 / club.get_height())
	draw_texture_rect(club, Rect2(Vector2(-club_size.x / 2, -club_size.y + 7), club_size), false)
	draw_set_transform(Vector2.ZERO)
