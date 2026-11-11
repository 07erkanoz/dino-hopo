extends SceneTree
const Assets = preload("res://scripts/nature_assets.gd")
const Plan = preload("res://scripts/nature_plan.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func inspect_nodes(node: Node) -> void:
	check(not node is CharacterBody2D, "Gameplay actor leaked into nature stage")
	var script = node.get_script()
	if script:
		check(not script.resource_path in ["res://scripts/game.gd","res://scripts/player.gd","res://scripts/dino.gd"], "Legacy game script in nature workspace")
	if node.has_meta("prop_index") and node.get_meta("prop_index") == 2:
		check(node.get_meta("height_units") <= 35, "Ordinary flower larger than scale contract")
	for child in node.get_children(): inspect_nodes(child)

func run() -> void:
	Assets.setup()
	for group in ["trees","props"]:
		for i in Assets.style[group].regions.size():
			var texture := Assets.sprite(group,i)
			var image := texture.atlas.get_image()
			check(image.get_format() == Image.FORMAT_RGBA8, "Missing alpha channel")
			var box: Rect2 = texture.region
			check(Rect2(Vector2.ZERO,texture.atlas.get_size()).encloses(box), "Region outside source")
			var has_content := false
			var has_clear := false
			for x in range(int(box.position.x),int(box.end.x),16):
				for y in range(int(box.position.y),int(box.end.y),16):
					var a: float = image.get_pixel(x,y).a
					if a > .8: has_content = true
					if a < .02: has_clear = true
			check(has_content and has_clear, "Empty or non-transparent nature sprite")
	var approval: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/characters/approved-sha256.json"))
	for path in approval: check(FileAccess.get_sha256("res://"+path)==approval[path], "Approved hero art changed")
	var scene = load("res://scenes/nature_workspace.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	check(scene.show_nature and scene.nature.support_trees.size()==4, "Nature view not connected")
	var data: Dictionary = scene.data
	for definition in data.vines:
		var vine: Node2D = scene.nature.vine_nodes[definition.id]
		check(vine.get_parent() is Marker2D and vine.get_parent().get_parent() is Sprite2D, "Vine not parented to actual source tree branch")
		check(vine.global_position.distance_to(Plan.vine_anchor(data,definition)) < .1, "Vine starts apart from its branch")
		var tree: Dictionary = {}
		for item in data.trees:
			if item.id == definition.tree_id: tree = item
		var model: Dictionary = Assets.style.trees.models[tree.model]
		var texture := Assets.sprite("trees",tree.model)
		var pixel := Vector2i(texture.region.position)+Vector2i(model.branch_pixel[0],model.branch_pixel[1])
		var color := texture.atlas.get_image().get_pixelv(pixel)
		check(color.a>.85 and color.r>color.g*1.15, "Socket is on transparent space/leaf rather than visible wood")
	inspect_nodes(scene)
	if failures==0: print("PASS:8 clean cartoon assets, immutable heroes, physical tree/branch/vine alignment, flower scale, nature-only scene")
	quit(1 if failures>0 else 0)
