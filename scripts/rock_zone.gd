extends Node2D
const Art = preload("res://scripts/art.gd")
var game: Node2D
var floor_y := 536.0
var origin_y := 70.0
var cycle := 0.0
var rock_y := 70.0
var falling := false
var velocity_y := 0.0

func _physics_process(delta: float) -> void:
	var nearby := false
	for hero in game.players:
		if absf(hero.position.x - position.x) < 430: nearby = true
	if not nearby and not falling: return
	cycle += delta
	if cycle >= 1.0 and not falling:
		falling = true
		rock_y = origin_y
		velocity_y = 0
	if falling:
		var previous := Vector2(position.x, rock_y)
		velocity_y += 1150 * delta
		rock_y += velocity_y * delta
		for hero in game.players:
			if hero.grace <= 0 and hero.position.distance_to(Vector2(position.x, rock_y + 35)) < 48:
				hero.hurt(position.x)
		var ray := PhysicsRayQueryParameters2D.create(previous, Vector2(position.x, rock_y + 22), 1)
		if rock_y > floor_y or not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			falling = false
			cycle = -2.2
	queue_redraw()

func _draw() -> void:
	if cycle >= 0 and cycle < 1 and not falling:
		for i in 4:
			draw_circle(Vector2(sin(cycle * 10 + i) * 17, origin_y + 10 + fmod(cycle * 110 + i * 28, 150)), 2 + i % 2, Color("a1794e"))
		draw_string(ThemeDB.fallback_font, Vector2(-7, origin_y + 13), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("fff3b5"))
	if falling:
		var texture := Art.sprite("jungle", 4)
		draw_texture_rect(texture, Rect2(-28, rock_y - 28, 56, 50), false)
