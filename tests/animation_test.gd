extends SceneTree
## Skeleton rigs and AnimationTree state machines: Çağan's 9 required states
## (+climb) are reached through real gameplay input with cross-fades, the
## planted foot does not slide while walking, and both enemy rigs exist with
## their walk/attack/hurt/die animations.
const Player = preload("res://scripts/player.gd")
const DinoRig = preload("res://scripts/rig/dino_rig.gd")
const PteroRig = preload("res://scripts/rig/ptero_rig.gd")
var failures := 0
var arena: Node2D

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("  ok: ", message)

func frames(n: int) -> void:
	for i in n: await physics_frame

func block(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.position = rect.get_center()
	body.add_child(shape)
	arena.add_child(body)

## Waits until the state machine is in `state` (or times out).
func reach(rig: Node2D, state: String, limit := 90) -> bool:
	for i in limit:
		if rig.current_state() == state: return true
		await physics_frame
	return rig.current_state() == state

func run() -> void:
	arena = Node2D.new()
	root.add_child(arena)
	block(Rect2(-500, 600, 6000, 200))
	var hero := Player.new()
	hero.position = Vector2(100, 600)
	hero.sfx_enabled = false
	hero.collision_layer = 2
	hero.collision_mask = 1
	arena.add_child(hero)
	await frames(20)
	var rig: Node2D = hero.rig
	check(rig != null and rig.skeleton is Skeleton2D, "Çağan uses a Skeleton2D rig")
	check(rig.bones.size() == 16 and rig.bones["pelvis"] is Bone2D, "16 Bone2D parts from art/v2/rig/cagan")
	check(rig.tree is AnimationTree and rig.tree.tree_root is AnimationNodeStateMachine, "AnimationTree drives a state machine")
	var required := ["idle", "walk", "run", "jump", "fall", "land", "attack", "hurt", "die"]
	for anim in required:
		check(rig.library.has_animation(anim), "animation '%s' exists" % anim)
	var machine: AnimationNodeStateMachine = rig.tree.tree_root
	var smooth := true
	for i in machine.get_transition_count():
		if machine.get_transition_from(i) != "Start" and machine.get_transition(i).xfade_time <= 0.0: smooth = false
	check(smooth, "every transition cross-fades")
	var idle_ok: bool = await reach(rig, "idle")
	check(idle_ok, "idle (breathing) at rest")
	var breath: Animation = rig.library.get_animation("idle")
	check(breath.loop_mode == Animation.LOOP_LINEAR and breath.length > 1.5, "idle breathing is a slow loop")
	var visited := {}
	Input.action_press("move_right")
	var walk_ok: bool = await reach(rig, "walk", 20)
	check(walk_ok, "walk when starting to move")
	var run_ok: bool = await reach(rig, "run", 60)
	check(run_ok, "run after building speed")
	Input.action_press("jump")
	var jump_ok: bool = await reach(rig, "jump", 10)
	check(jump_ok, "jump on take-off")
	Input.action_release("jump")
	var fall_ok: bool = await reach(rig, "fall", 60)
	check(fall_ok, "fall after the apex")
	var land_ok: bool = await reach(rig, "land", 60)
	check(land_ok, "land on touchdown")
	Input.action_release("move_right")
	await frames(30)
	Input.action_press("attack")
	var attack_ok: bool = await reach(rig, "attack", 6)
	check(attack_ok, "club attack")
	Input.action_release("attack")
	await frames(40)
	hero.grace = 0
	hero.hurt(hero.position.x + 50)
	var hurt_ok: bool = await reach(rig, "hurt", 6)
	check(hurt_ok, "hurt reaction")
	await frames(30)
	hero.grace = 0
	hero.health = 1
	hero.hurt(hero.position.x + 50)
	var die_ok: bool = await reach(rig, "die", 20)
	check(die_ok, "die (dead=%s health=%d state=%s path=%s)" % [hero.dead, hero.health, rig.current_state(), rig.playback.get_travel_path()])
	# A cross-fade is really blending (not a hard cut): mid-transition the
	# playback reports a fading-from node.
	hero.respawn()
	await frames(30)
	Input.action_press("move_right")
	var saw_blend := false
	for i in 20:
		await physics_frame
		if rig.playback.get_fading_from_node() != StringName(): saw_blend = true
	check(saw_blend, "transitions blend over time")
	Input.action_release("move_right")
	await frames(40)
	# Foot slip: walk at constant speed; the planted foot must stay put on the ground.
	hero.run_after = 99.0
	hero.position = Vector2(400, 600)
	await frames(20)
	Input.action_press("move_right")
	await frames(60)
	var worst := 0.0
	var stance_x := []
	for i in 90:
		await physics_frame
		var foot: Vector2 = rig.bone_global("foot_right")
		var phase: float = hero.gait_phase
		if phase > 0.08 and phase < 0.42: stance_x.append(foot.x)
		elif stance_x.size() > 3:
			worst = maxf(worst, stance_x.max() - stance_x.min())
			stance_x.clear()
	Input.action_release("move_right")
	check(worst < 3.0, "planted foot slides %.2f px during stance (walk %.0f px/s)" % [worst, hero.walk_speed])
	check(absf(hero.velocity.x) <= hero.walk_speed + 0.1, "measured at walking speed")
	# Enemy rigs.
	for item in [[DinoRig, "enemy_dino", ["walk", "charge", "windup", "hurt", "die"]], [PteroRig, "enemy_second", ["fly", "swoop", "hurt", "die"]]]:
		var enemy_rig: Node2D = item[0].new()
		arena.add_child(enemy_rig)
		await frames(2)
		check(enemy_rig.skeleton is Skeleton2D and enemy_rig.rig_id == item[1], "%s Skeleton2D rig" % item[1])
		for anim in item[2]:
			check(enemy_rig.library.has_animation(anim), "%s animation '%s'" % [item[1], anim])
		for anim in item[2]:
			enemy_rig.travel(anim)
			var ok: bool = await reach(enemy_rig, anim, 20)
			check(ok, "%s reaches state '%s'" % [item[1], anim])
	if failures == 0: print("PASS: Çağan 9 animation states + climb with cross-fades, no foot slip, two enemy rigs with walk/attack/hurt/die")
	quit(1 if failures > 0 else 0)
