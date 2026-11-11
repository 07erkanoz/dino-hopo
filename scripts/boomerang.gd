extends Node2D
const Art = preload("res://scripts/art.gd")
var hero: CharacterBody2D
var game: Node2D
var direction := 1.0
var returning := false
var lifetime := 0.0
var hit_targets: Dictionary = {}

func _physics_process(delta: float) -> void:
	if not is_instance_valid(hero):
		queue_free()
		return
	lifetime += delta
	rotation += delta * 18 * direction
	var previous := global_position
	if lifetime > 0.58: returning = true
	var destination := hero.global_position + Vector2(0, -50)
	if returning:
		global_position = global_position.move_toward(destination, 740 * delta)
	else:
		global_position.x += direction * 560 * delta
	# Terrain can trap a boomerang on BOTH outward and returning legs.
	var ray := PhysicsRayQueryParameters2D.create(previous, global_position, 1)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
		lose()
		return
	for target in game.targets:
		if not is_instance_valid(target): continue
		var key := "%s:%s" % [target.get_instance_id(), returning]
		if hit_targets.has(key): continue
		var center: Vector2 = target.hit_center()
		var closest := Geometry2D.get_closest_point_to_segment(center, previous, global_position)
		if closest.distance_to(center) < target.hit_radius:
			target.stun()
			hit_targets[key] = true
	if returning and global_position.distance_to(destination) < 22:
		hero.boomerang_active = false
		queue_free()
	elif lifetime > 3.2:
		lose()

func lose() -> void:
	if is_instance_valid(hero):
		hero.has_boomerang = false
		hero.boomerang_active = false
	if is_instance_valid(game): game.notify_boomerang_lost()
	queue_free()

func _exit_tree() -> void:
	if is_instance_valid(hero): hero.boomerang_active = false

func _draw() -> void:
	var texture := Art.sprite("equipment", 1)
	var size := texture.get_size() * (48.0 / texture.get_width())
	draw_texture_rect(texture, Rect2(-size / 2, size), false)
