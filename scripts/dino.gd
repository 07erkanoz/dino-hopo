extends CharacterBody2D
const Art = preload("res://scripts/art.gd")
var species := 0
var home_x := 0.0
var direction := -1.0
var stunned := 0.0
var stun_count := 0

func _ready() -> void:
	home_x = position.x
	collision_layer = 4
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 29
	collision.shape = circle
	collision.position.y = -29
	add_child(collision)

func stun() -> void:
	stunned = 2.7
	stun_count += 1
	queue_redraw()

func _physics_process(delta: float) -> void:
	stunned = maxf(0.0, stunned - delta)
	velocity.x = direction * 23 if stunned <= 0 else 0.0
	velocity.y = minf(velocity.y + delta * 1700, 1000)
	move_and_slide()
	if is_on_wall() or absf(position.x - home_x) > 65:
		direction *= -1
	queue_redraw()

func _draw() -> void:
	var image := Art.sprite("creatures", species)
	var size := image.get_size() * (88.0 / image.get_height())
	draw_set_transform(Vector2.ZERO, 0, Vector2(-direction, 1))
	draw_texture_rect(image, Rect2(Vector2(-size.x / 2, -size.y), size), false, Color(1, 1, 1, 0.75 if stunned > 0 else 1.0))
	draw_set_transform(Vector2.ZERO)
	if stunned > 0:
		for i in 3:
			var theta := Time.get_ticks_msec() / 300.0 + i * TAU / 3
			var center := Vector2(cos(theta) * 26, -102 + sin(theta) * 7)
			draw_texture_rect(Art.sprite("equipment", 3), Rect2(center - Vector2(9,9), Vector2(18,18)), false)
