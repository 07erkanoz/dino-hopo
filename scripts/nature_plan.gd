extends RefCounted
## Geography and dependent nature placements only. No combat or actors.
const PATH := "res://world/nature/01-map.json"

static func read() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))

static func surface_at(data: Dictionary, x: float) -> float:
	var points: Array = data.surface
	for i in range(1, points.size()):
		if x <= points[i][0]:
			var a: Array = points[i-1]
			var b: Array = points[i]
			return lerpf(a[1], b[1], clampf((x-a[0]) / float(b[0]-a[0]), 0, 1))
	return float(points[-1][1])

static func tree_root(data: Dictionary, tree: Dictionary) -> Vector2:
	return Vector2(tree.x, surface_at(data, tree.x))

static func vine_anchor(data: Dictionary, vine: Dictionary) -> Vector2:
	for tree in data.trees:
		if tree.id != vine.tree_id: continue
		for branch in tree.branches:
			if branch.id == vine.branch_id:
				return tree_root(data, tree) + Vector2(branch.offset[0],branch.offset[1])
	push_error("Vine has no supporting tree/branch: " + str(vine.id))
	return Vector2.INF
