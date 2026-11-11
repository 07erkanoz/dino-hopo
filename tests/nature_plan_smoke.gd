extends SceneTree
const Plan = preload("res://scripts/nature_plan.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	var data := Plan.read()
	check(data.status == "map_draft", "Do not label unfinished nature as approved")
	for key in ["enemies","weapons","fruit","quests","rock_zones","spawns"]:
		check(not data.has(key), "Gameplay leaked into the nature plan")
	var end := 0
	for region in data.regions:
		check(region.from == end and region.to > region.from, "Region gap/overlap")
		end = region.to
	check(end == data.width, "Regions do not cover whole map")
	var tree_ids: Dictionary = {}
	for tree in data.trees:
		check(not tree_ids.has(tree.id), "Duplicate support tree id")
		tree_ids[tree.id] = true
		check(tree.layer == "world", "Physical support tree is in a parallax decoration layer")
		var root := Plan.tree_root(data,tree)
		check(is_equal_approx(root.y,Plan.surface_at(data,root.x)), "Floating tree root")
	for vine in data.vines:
		check(not vine.has("start") and not vine.has("position"), "Vine must derive start from its support")
		var anchor := Plan.vine_anchor(data,vine)
		check(anchor.is_finite() and vine.length > 0, "Unanchored vine")
		check(anchor.y+vine.length <= Plan.surface_at(data,anchor.x)+5, "Vine extends underground")
	for route in data.routes:
		for point in route.points:
			check(point[0]>=0 and point[0]<=data.width and point[1]>=0 and point[1]<=data.height, "Route outside map")
	var scene = load("res://scenes/nature_workspace.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	check(scene.ready_for_review, "Nature workspace did not start")
	for child in scene.get_children():
		check(not child is CharacterBody2D, "Actor in map-only workspace")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/nature_workspace.tscn", "Game prototype still starts by default")
	if failures == 0: print("PASS: separate map data, continuous regions, terrain-bound trees, branch-bound vines, map-only default scene")
	quit(1 if failures > 0 else 0)
