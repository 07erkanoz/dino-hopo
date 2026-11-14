extends Node2D
## Skeleton2D rig built from art/v2/manifest.json.
## Every part is a Sprite2D attached to its Bone2D; poses are dictionaries of
## bone rotation offsets (degrees, relative to rest) and root position offsets
## (art pixels). Animations always key every bone so AnimationTree blends cleanly.

const MANIFEST := "res://art/v2/manifest.json"
static var _manifest: Dictionary = {}

var rig_id := ""
var skeleton: Skeleton2D
var bones: Dictionary = {}        # id -> Bone2D
var bone_paths: Dictionary = {}   # id -> NodePath relative to this node
var parts: Dictionary = {}        # id -> Sprite2D
var rest_rotation: Dictionary = {}
var rest_position: Dictionary = {}
var parent_of: Dictionary = {}
var root_id := ""
var player: AnimationPlayer
var tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var library := AnimationLibrary.new()
var seek_states: Array[String] = []

static func manifest() -> Dictionary:
	if _manifest.is_empty():
		_manifest = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	return _manifest

static func rig_data(id: String) -> Dictionary:
	for rig in manifest().rigs:
		if rig.id == id: return rig
	push_error("Unknown rig " + id)
	return {}

## anchor: art-space point placed at this node's origin (usually ground under the root).
func build(id: String, anchor: Vector2) -> void:
	rig_id = id
	var data := rig_data(id)
	root_id = data.root
	skeleton = Skeleton2D.new()
	skeleton.name = "Skeleton"
	skeleton.position = -anchor
	add_child(skeleton)
	var part_info: Dictionary = {}
	for part in data.parts: part_info[part.id] = part
	for bone_data in data.bones:
		var bone := Bone2D.new()
		bone.name = bone_data.id
		bone.position = Vector2(bone_data.position[0], bone_data.position[1])
		bone.rotation = deg_to_rad(float(bone_data.rotation_degrees_godot))
		bone.rest = bone.transform
		bone.set_autocalculate_length_and_angle(false)
		bone.set_length(16.0)
		var parent: Node = skeleton if bone_data.parent == null else bones[bone_data.parent]
		parent.add_child(bone)
		bones[bone_data.id] = bone
		parent_of[bone_data.id] = bone_data.parent
		rest_rotation[bone_data.id] = bone.rotation
		rest_position[bone_data.id] = bone.position
		var sprite := Sprite2D.new()
		sprite.name = "Art"
		sprite.texture = load("res://" + bone_data.asset)
		sprite.centered = false
		sprite.offset = -Vector2(bone_data.pivot[0], bone_data.pivot[1])
		sprite.z_index = int(round(float(bone_data.draw_order) * 2.0))
		bone.add_child(sprite)
		parts[bone_data.id] = sprite
	for id_key in bones:
		bone_paths[id_key] = get_path_to(bones[id_key])
	player = AnimationPlayer.new()
	player.name = "AnimationPlayer"
	add_child(player)
	player.root_node = player.get_path_to(self)
	player.add_animation_library("", library)

## Bone position in skeleton (art) space, using the bones' current transforms.
func skeleton_point(id: String, local := Vector2.ZERO) -> Vector2:
	var xf := Transform2D.IDENTITY
	var cursor = id
	while cursor != null:
		xf = bones[cursor].transform * xf
		cursor = parent_of[cursor]
	return xf * local

func bone_global(id: String, local := Vector2.ZERO) -> Vector2:
	return bones[id].global_transform * local

## Two-bone IK. Returns rotation offsets (degrees, relative to rest) for upper,
## lower and foot so the foot pivot lands on `target` (skeleton space).
## knee_sign +1 bends the knee toward +x, -1 toward -x. foot_angle is the
## desired absolute foot rotation in degrees (0 = rest / flat).
func solve_leg(pose: Dictionary, upper: String, lower: String, foot: String, target: Vector2, knee_sign: float, foot_angle := 0.0) -> void:
	var root_rot: float = rest_rotation[root_id] + deg_to_rad(pose.rot.get(root_id, 0.0))
	var root_pos: Vector2 = rest_position[root_id] + pose.pos.get(root_id, Vector2.ZERO)
	var local := (target - root_pos).rotated(-root_rot)
	var hip: Vector2 = rest_position[upper]
	var v1: Vector2 = rest_position[lower]
	var v2: Vector2 = rest_position[foot]
	var l1 := v1.length()
	var l2 := v2.length()
	var to_target := local - hip
	var d := clampf(to_target.length(), absf(l1 - l2) + 0.5, (l1 + l2) * 0.999)
	var cos_a := clampf((l1 * l1 + d * d - l2 * l2) / (2.0 * l1 * d), -1.0, 1.0)
	var a1 := acos(cos_a)
	var dir := to_target.normalized()
	if dir == Vector2.ZERO: dir = Vector2.DOWN
	var knee := hip + dir.rotated(-a1 * knee_sign) * l1
	var ankle := hip + dir * d
	var upper_abs := (knee - hip).angle() - v1.angle()
	var lower_rel := (ankle - knee).angle() - v2.angle() - upper_abs
	pose.rot[upper] = rad_to_deg(wrapf(upper_abs - rest_rotation[upper], -PI, PI))
	pose.rot[lower] = rad_to_deg(wrapf(lower_rel - rest_rotation[lower], -PI, PI))
	var chain: float = root_rot + upper_abs + lower_rel
	pose.rot[foot] = rad_to_deg(wrapf(deg_to_rad(foot_angle) - chain - rest_rotation[foot], -PI, PI))

## Rest ankle (foot bone pivot) position in skeleton space.
func rest_point(id: String) -> Vector2:
	var p := Vector2.ZERO
	var cursor = id
	var xf := Transform2D.IDENTITY
	while cursor != null:
		xf = Transform2D(rest_rotation[cursor], rest_position[cursor]) * xf
		cursor = parent_of[cursor]
	return xf * p

static func pose(rot := {}, pos := {}) -> Dictionary:
	return {"rot": rot.duplicate(), "pos": pos.duplicate()}

static func blend_pose(a: Dictionary, b: Dictionary, t: float) -> Dictionary:
	var out := pose()
	for k in a.rot.keys() + b.rot.keys():
		out.rot[k] = lerpf(a.rot.get(k, 0.0), b.rot.get(k, 0.0), t)
	for k in a.pos.keys() + b.pos.keys():
		out.pos[k] = a.pos.get(k, Vector2.ZERO).lerp(b.pos.get(k, Vector2.ZERO), t)
	return out

## keys: Array of [time, pose]. Every bone gets a rotation track; the root also
## gets a position track. Linear-angle interpolation for dense sampled cycles,
## cubic-angle for sparse hand-authored keys.
func add_animation(anim_name: String, length: float, loop: bool, keys: Array, cubic := true) -> Animation:
	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	for id in bones:
		var track := anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track, NodePath(str(bone_paths[id]) + ":rotation"))
		anim.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC_ANGLE if cubic else Animation.INTERPOLATION_LINEAR_ANGLE)
		anim.value_track_set_update_mode(track, Animation.UPDATE_CONTINUOUS)
		for key in keys:
			var p: Dictionary = key[1]
			anim.track_insert_key(track, key[0], rest_rotation[id] + deg_to_rad(p.rot.get(id, 0.0)))
	var pos_track := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(pos_track, NodePath(str(bone_paths[root_id]) + ":position"))
	anim.track_set_interpolation_type(pos_track, Animation.INTERPOLATION_CUBIC if cubic else Animation.INTERPOLATION_LINEAR)
	for key in keys:
		var p: Dictionary = key[1]
		anim.track_insert_key(pos_track, key[0], rest_position[root_id] + p.pos.get(root_id, Vector2.ZERO))
	library.add_animation(anim_name, anim)
	return anim

## Sample a pose function f(phase) -> pose at `samples` points for a cycle.
func add_sampled(anim_name: String, length: float, loop: bool, samples: int, f: Callable) -> Animation:
	var keys := []
	for i in samples + 1:
		var phase := float(i) / float(samples)
		keys.append([phase * length, f.call(0.0 if loop and i == samples else phase)])
	return add_animation(anim_name, length, loop, keys, false)

## State machine over the library. Every state can reach every other with a
## short cross-fade; `seek` states are driven by an external phase (distance
## travelled) through a TimeSeek node so feet never slide.
func build_tree(states: Array, start: String, seek: Array[String], xfade := 0.12, xfades := {}) -> void:
	seek_states = seek
	var machine := AnimationNodeStateMachine.new()
	var x := 0.0
	for state in states:
		var anim_node := AnimationNodeAnimation.new()
		anim_node.animation = state
		if state in seek:
			var blend := AnimationNodeBlendTree.new()
			blend.add_node("anim", anim_node, Vector2(0, 0))
			blend.add_node("seek", AnimationNodeTimeSeek.new(), Vector2(200, 0))
			blend.connect_node("seek", 0, "anim")
			blend.connect_node("output", 0, "seek")
			machine.add_node(state, blend, Vector2(x, 0))
		else:
			machine.add_node(state, anim_node, Vector2(x, 0))
		x += 160
	for a in states:
		for b in states:
			if a == b: continue
			var t := AnimationNodeStateMachineTransition.new()
			t.xfade_time = float(xfades.get(b, xfade))
			t.reset = not (b in seek)
			machine.add_transition(a, b, t)
	var begin := AnimationNodeStateMachineTransition.new()
	begin.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	machine.add_transition("Start", start, begin)
	tree = AnimationTree.new()
	tree.name = "AnimationTree"
	add_child(tree)
	tree.tree_root = machine
	tree.anim_player = tree.get_path_to(player)
	tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	tree.active = true
	playback = tree.get("parameters/playback")

func travel(state: String, restart := false) -> void:
	if playback == null: return
	if restart:
		playback.start(state, true)
	elif playback.get_current_node() != state:
		playback.travel(state)

func current_state() -> String:
	return "" if playback == null else String(playback.get_current_node())

## Drive distance-phased cycles: phase in [0,1).
func set_cycle_phase(phase: float) -> void:
	for state in seek_states:
		var anim := library.get_animation(state)
		tree.set("parameters/%s/seek/seek_request" % state, fposmod(phase, 1.0) * anim.length)

## Immediately apply a pose (used by tools and tests without the tree).
func apply_pose(p: Dictionary) -> void:
	for id in bones:
		bones[id].rotation = rest_rotation[id] + deg_to_rad(p.rot.get(id, 0.0))
	bones[root_id].position = rest_position[root_id] + p.pos.get(root_id, Vector2.ZERO)
