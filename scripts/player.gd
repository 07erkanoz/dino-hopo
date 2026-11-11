extends CharacterBody2D

var slot := 0
var tint := Color("efa444")
var touch_axis := 0.0
var touch_jump := false
var checkpoint := Vector2.ZERO
var coyote := 0.0
var jump_buffer := 0.0
var facing := 1.0

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 19.0
	capsule.height = 66.0
	shape.shape = capsule
	shape.position.y = -33.0
	add_child(shape)

func _physics_process(delta: float) -> void:
	var left := KEY_A if slot == 0 else KEY_LEFT
	var right := KEY_D if slot == 0 else KEY_RIGHT
	var jump := KEY_W if slot == 0 else KEY_UP
	var axis := float(Input.is_physical_key_pressed(right)) - float(Input.is_physical_key_pressed(left))
	if slot == 0 and touch_axis != 0.0:
		axis = touch_axis
	if slot in Input.get_connected_joypads():
		var stick := Input.get_joy_axis(slot, JOY_AXIS_LEFT_X)
		if absf(stick) > 0.2:
			axis = stick
	var jumping := Input.is_physical_key_pressed(jump) or Input.is_joy_button_pressed(slot, JOY_BUTTON_A)
	if slot == 0:
		jumping = jumping or touch_jump
	if jumping and not _was_jumping:
		jump_buffer = 0.13
	_was_jumping = jumping
	jump_buffer = maxf(0.0, jump_buffer - delta)
	coyote = 0.12 if is_on_floor() else maxf(0.0, coyote - delta)
	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = -650.0
		coyote = 0.0
		jump_buffer = 0.0
	if not jumping and velocity.y < -240.0:
		velocity.y += 2000.0 * delta
	velocity.y = minf(velocity.y + 1700.0 * delta, 1100.0)
	velocity.x = move_toward(velocity.x, axis * 300.0, 2200.0 * delta)
	if axis != 0.0:
		facing = signf(axis)
	move_and_slide()
	position.x = clampf(position.x, 28.0, 3150.0)
	if position.y > 950.0:
		respawn()
	queue_redraw()

var _was_jumping := false

func respawn() -> void:
	position = checkpoint
	velocity = Vector2.ZERO

const Art = preload("res://scripts/art.gd")

func _draw() -> void:
	var pose := 0
	if not is_on_floor():
		pose = 3
	elif absf(velocity.x) > 10.0:
		pose = 1 + (int(Time.get_ticks_msec() / 140) % 2)
	var texture := Art.sprite("heroes", slot * 4 + pose)
	var source_size := texture.get_size()
	var artwork_scale := 0.25 if slot == 0 else 0.24
	var size := source_size * artwork_scale
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_texture_rect(texture, Rect2(Vector2(-size.x / 2.0, -size.y), size), false)
	draw_set_transform(Vector2.ZERO)
