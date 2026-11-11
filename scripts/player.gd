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

func _draw() -> void:
	# Temporary original vector-style test character; final cartoon sprite pending.
	var bounce := sin(Time.get_ticks_msec() * 0.02) * 3.0 if absf(velocity.x) > 10.0 and is_on_floor() else 0.0
	draw_circle(Vector2(0, -34 + bounce), 24, tint)
	draw_circle(Vector2(0, -64 + bounce), 23, Color("ffdbac"))
	draw_circle(Vector2(-7, -81 + bounce), 14, Color("593d35"))
	draw_circle(Vector2(10 * facing, -67 + bounce), 4, Color("203f44"))
	draw_circle(Vector2(22 * facing, -59 + bounce), 9, Color("ffdbac"))
	draw_line(Vector2(-13, -12), Vector2(-18, -3), Color("593d35"), 11)
	draw_line(Vector2(12, -12), Vector2(19, -3), Color("593d35"), 11)
	draw_circle(Vector2(-9, -33 + bounce), 4, Color("593d35"))
	draw_circle(Vector2(10, -42 + bounce), 4, Color("593d35"))
