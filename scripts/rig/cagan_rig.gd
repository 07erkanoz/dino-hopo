extends "res://scripts/rig/rig.gd"
## Çağan: 16-part Skeleton2D rig with IK-generated locomotion.
## Walk/run feet are solved with two-bone IK so the planted foot moves backward
## exactly as far as the body travels: one full cycle covers WALK_STRIDE /
## RUN_STRIDE art pixels, and the player advances the cycle by distance.

const GROUND_Y := 455.0          # sole line in art pixels
const ANKLE_Y := 421.0           # foot pivot height at rest
const ART_SCALE := 128.0 / 450.0 # manifest: 450 art px -> 128 world units
const WALK_HALF_STEP := 44.0
const RUN_HALF_STEP := 50.0
const RUN_STANCE := 0.32
const WALK_STRIDE := WALK_HALF_STEP * 4.0                 # art px per cycle
const RUN_STRIDE := RUN_HALF_STEP * 2.0 / RUN_STANCE      # art px per cycle
const STATES := ["idle", "walk", "run", "jump", "fall", "land", "attack", "hurt", "die", "climb"]
## The club strike follows the gameplay hit windows (8 phases, 0.58 s).
const ATTACK_LENGTH := 0.58

var hip_r := Vector2.ZERO
var hip_l := Vector2.ZERO

func _init() -> void:
	name = "CaganRig"

func _ready() -> void:
	build("cagan", Vector2(145, GROUND_Y))
	hip_r = rest_point("thigh_right")
	hip_l = rest_point("thigh_left")
	add_sampled("idle", 2.4, true, 24, idle_pose)
	add_sampled("walk", 1.0, true, 32, walk_pose)
	add_sampled("run", 1.0, true, 32, run_pose)
	add_sampled("climb", 0.8, true, 16, climb_pose)
	add_animation("jump", 0.32, false, [[0.0, takeoff_pose()], [0.1, stretch_pose()], [0.32, tuck_pose()]])
	add_sampled("fall", 0.7, true, 14, fall_pose)
	add_animation("land", 0.24, false, [[0.0, squat_pose(22.0)], [0.1, squat_pose(16.0)], [0.24, idle_pose(0.0)]])
	add_animation("attack", ATTACK_LENGTH, false, attack_keys())
	add_animation("hurt", 0.42, false, [[0.0, idle_pose(0.0)], [0.06, hurt_pose(1.0)], [0.2, hurt_pose(0.8)], [0.42, hurt_pose(0.25)]])
	add_animation("die", 1.2, false, die_keys())
	add_animation("RESET", 0.01, false, [[0.0, pose()]])
	build_tree(STATES, "idle", ["walk", "run"], 0.12, {"attack": 0.06, "hurt": 0.05, "die": 0.08, "land": 0.06, "jump": 0.07, "fall": 0.18})

func legs(p: Dictionary, right: Vector2, left: Vector2, right_angle := 0.0, left_angle := 0.0) -> Dictionary:
	solve_leg(p, "thigh_right", "calf_right", "foot_right", right, 1.0, right_angle)
	solve_leg(p, "thigh_left", "calf_left", "foot_left", left, 1.0, left_angle)
	return p

func pelvis_y(p: Dictionary) -> float:
	return 245.0 + p.pos.get("pelvis", Vector2.ZERO).y

func smooth(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)

## Body height so the planted (straight-ish) leg reaches the ground.
func stance_drop(dx: float, reach := 0.975) -> float:
	var length: float = (rest_position["calf_right"].length() + rest_position["foot_right"].length()) * reach
	return 136.0 - sqrt(maxf(1.0, length * length - dx * dx))

func idle_pose(phase: float) -> Dictionary:
	var breath := sin(phase * TAU)
	var p := pose({
		"torso": -1.0 + 1.2 * breath, "head": 1.0 - 1.6 * sin(phase * TAU - 0.7),
		"upper_arm_right": -6.0 + 2.0 * sin(phase * TAU - 0.4), "forearm_right": -10.0, "hand_right": 4.0, "club": 6.0,
		"upper_arm_left": 3.0 - 2.5 * sin(phase * TAU - 0.5), "forearm_left": -6.0 - 2.0 * breath,
	}, {"pelvis": Vector2(0, 3.0 + 2.2 * breath)})
	return legs(p, Vector2(184, ANKLE_Y), Vector2(108, ANKLE_Y))

## Foot offset along the ground for a stance/swing cycle.
func gait_foot(phase: float, half: float, stance: float, lift: float) -> Vector3:
	phase = fposmod(phase, 1.0)
	if phase < stance:
		var u := phase / stance
		return Vector3(half * (1.0 - 2.0 * u), 0.0, 0.0)
	var s := (phase - stance) / (1.0 - stance)
	var height := lift * sin(PI * pow(s, 0.8))
	return Vector3(-half + 2.0 * half * smooth(s), height, 26.0 * sin(PI * s) - 10.0 * s)

func walk_pose(phase: float) -> Dictionary:
	var r := gait_foot(phase, WALK_HALF_STEP, 0.5, 20.0)
	var l := gait_foot(phase + 0.5, WALK_HALF_STEP, 0.5, 20.0)
	var planted := r.x if fposmod(phase, 1.0) < 0.5 else l.x
	var swing := cos(phase * TAU)
	var p := pose({
		"torso": 5.0 + 1.5 * sin(phase * TAU * 2.0 - 0.5), "head": -3.0 - 1.5 * sin(phase * TAU * 2.0 - 1.4),
		"upper_arm_right": 12.0 * swing - 6.0, "forearm_right": -16.0 - 6.0 * maxf(0.0, -swing), "hand_right": 6.0, "club": 8.0 + 6.0 * sin(phase * TAU - 1.0),
		"upper_arm_left": -24.0 * swing, "forearm_left": -12.0 - 10.0 * maxf(0.0, swing), "hand_left": 4.0 * swing,
		"pelvis": 2.0 * sin(phase * TAU),
	}, {"pelvis": Vector2(0, stance_drop(planted + 4.0))})
	return legs(p, Vector2(hip_r.x + 4.0 + r.x, ANKLE_Y - r.y), Vector2(hip_l.x + 4.0 + l.x, ANKLE_Y - l.y), r.z, l.z)

func run_pose(phase: float) -> Dictionary:
	var r := gait_foot(phase, RUN_HALF_STEP, RUN_STANCE, 46.0)
	var l := gait_foot(phase + 0.5, RUN_HALF_STEP, RUN_STANCE, 46.0)
	var swing := cos(phase * TAU)
	var bounce := cos(TAU * 2.0 * (phase - RUN_STANCE * 0.5))
	var p := pose({
		"torso": 11.0 + 2.0 * sin(phase * TAU * 2.0), "head": -9.0 - 2.5 * sin(phase * TAU * 2.0 - 1.2),
		"upper_arm_right": 26.0 * swing - 12.0, "forearm_right": -34.0, "hand_right": 16.0, "club": 34.0 + 8.0 * sin(phase * TAU - 1.2),
		"upper_arm_left": -42.0 * swing, "forearm_left": -48.0 - 12.0 * maxf(0.0, swing), "hand_left": 0.0,
		"pelvis": 3.0 * sin(phase * TAU),
	}, {"pelvis": Vector2(0, 18.0 + 5.0 * bounce)})
	return legs(p, Vector2(hip_r.x + 6.0 + r.x, ANKLE_Y - r.y), Vector2(hip_l.x + 6.0 + l.x, ANKLE_Y - l.y), r.z * 1.3, l.z * 1.3)

func takeoff_pose() -> Dictionary:
	var p := pose({"torso": 12.0, "head": -6.0, "upper_arm_right": 30.0, "forearm_right": -20.0, "club": 10.0,
		"upper_arm_left": 40.0, "forearm_left": -20.0}, {"pelvis": Vector2(0, 18)})
	return legs(p, Vector2(186, ANKLE_Y), Vector2(104, ANKLE_Y))

func stretch_pose() -> Dictionary:
	var p := pose({"torso": 2.0, "head": -10.0, "upper_arm_right": -70.0, "forearm_right": -30.0, "hand_right": 30.0, "club": 50.0,
		"upper_arm_left": -150.0, "forearm_left": -10.0}, {"pelvis": Vector2(0, -6)})
	var y := pelvis_y(p) + 40.0
	return legs(p, Vector2(hip_r.x + 6.0, y + 132.0), Vector2(hip_l.x - 10.0, y + 128.0), 40.0, 45.0)

func tuck_pose() -> Dictionary:
	var p := pose({"torso": 6.0, "head": -6.0, "upper_arm_right": -60.0, "forearm_right": -40.0, "hand_right": 30.0, "club": 50.0,
		"upper_arm_left": -120.0, "forearm_left": -30.0}, {"pelvis": Vector2(0, -4)})
	var y := pelvis_y(p) + 40.0
	return legs(p, Vector2(hip_r.x + 34.0, y + 86.0), Vector2(hip_l.x - 18.0, y + 110.0), 20.0, 40.0)

func fall_pose(phase: float) -> Dictionary:
	var flail := sin(phase * TAU)
	var p := pose({"torso": -4.0 + 2.0 * flail, "head": -14.0, "upper_arm_right": -84.0 + 12.0 * flail, "forearm_right": -24.0, "hand_right": 30.0, "club": 40.0,
		"upper_arm_left": -160.0 - 18.0 * flail, "forearm_left": -18.0 + 10.0 * flail}, {"pelvis": Vector2(0, -2)})
	var y := pelvis_y(p) + 40.0
	return legs(p, Vector2(hip_r.x + 22.0 + 6.0 * flail, y + 120.0), Vector2(hip_l.x - 20.0 - 6.0 * flail, y + 124.0), 18.0, 24.0)

func squat_pose(depth: float) -> Dictionary:
	var p := pose({"torso": 14.0, "head": -10.0, "upper_arm_right": -30.0, "forearm_right": -30.0, "club": 20.0,
		"upper_arm_left": -36.0, "forearm_left": -24.0}, {"pelvis": Vector2(0, depth)})
	return legs(p, Vector2(190, ANKLE_Y), Vector2(100, ANKLE_Y))

func climb_pose(phase: float) -> Dictionary:
	var s := sin(phase * TAU)
	var p := pose({"torso": -4.0, "head": -16.0, "upper_arm_right": -165.0 + 18.0 * s, "forearm_right": -20.0 + 16.0 * s, "hand_right": 40.0, "club": 140.0,
		"upper_arm_left": -165.0 - 18.0 * s, "forearm_left": -20.0 - 16.0 * s}, {"pelvis": Vector2(0, -2)})
	var y := pelvis_y(p) + 40.0
	return legs(p, Vector2(hip_r.x + 22.0, y + 100.0 + 22.0 * s), Vector2(hip_l.x + 12.0, y + 100.0 - 22.0 * s), 10.0, 10.0)

func attack_pose(torso: float, arm: float, forearm: float, hand: float, club: float, depth: float, lunge: float) -> Dictionary:
	var p := pose({"torso": torso, "head": -torso * 0.6, "upper_arm_right": arm, "forearm_right": forearm, "hand_right": hand, "club": club,
		"upper_arm_left": -torso * 1.4 - 10.0, "forearm_left": -30.0}, {"pelvis": Vector2(lunge * 0.4, depth)})
	return legs(p, Vector2(184 + lunge, ANKLE_Y), Vector2(104 - lunge * 0.5, ANKLE_Y))

## Windup -> strike -> follow-through overshoot -> settle (weight and drag).
func attack_keys() -> Array:
	return [
		[0.0, attack_pose(-2.0, -10.0, -12.0, 6.0, 8.0, 4.0, 0.0)],
		[0.04, attack_pose(-6.0, 60.0, -10.0, 10.0, 10.0, 8.0, 0.0)],
		[0.19, attack_pose(-14.0, 168.0, 34.0, 30.0, -10.0, 12.0, 4.0)],
		[0.25, attack_pose(10.0, -40.0, -10.0, 40.0, 80.0, 14.0, 22.0)],
		[0.31, attack_pose(20.0, -88.0, -4.0, 60.0, 98.0, 18.0, 28.0)],
		[0.39, attack_pose(24.0, -62.0, -6.0, 80.0, 106.0, 18.0, 28.0)],
		[0.48, attack_pose(12.0, -34.0, -14.0, 40.0, 50.0, 12.0, 16.0)],
		[ATTACK_LENGTH, attack_pose(0.0, -8.0, -12.0, 6.0, 10.0, 5.0, 2.0)],
	]

func hurt_pose(amount: float) -> Dictionary:
	var p := pose({"torso": -18.0 * amount, "head": -18.0 * amount, "upper_arm_right": 24.0 * amount, "forearm_right": -20.0 * amount, "hand_right": 10.0 * amount, "club": -20.0 * amount,
		"upper_arm_left": -80.0 * amount, "forearm_left": -20.0 * amount, "pelvis": -6.0 * amount}, {"pelvis": Vector2(-10.0 * amount, 8.0 * amount)})
	return legs(p, Vector2(190, ANKLE_Y), Vector2(96, ANKLE_Y))

func die_keys() -> Array:
	var buckle := pose({"torso": 16.0, "head": 20.0, "upper_arm_right": 20.0, "forearm_right": -30.0, "club": 30.0,
		"upper_arm_left": 10.0, "forearm_left": -40.0}, {"pelvis": Vector2(0, 40)})
	legs(buckle, Vector2(196, ANKLE_Y), Vector2(96, ANKLE_Y))
	var lying := pose({"pelvis": -84.0, "torso": -4.0, "head": 10.0, "upper_arm_right": -60.0, "forearm_right": -20.0, "hand_right": 30.0, "club": 60.0,
		"upper_arm_left": -120.0, "forearm_left": -10.0, "thigh_right": -60.0, "calf_right": 50.0, "foot_right": 10.0,
		"thigh_left": -40.0, "calf_left": 30.0, "foot_left": 10.0}, {"pelvis": Vector2(-30, 170)})
	var bounce := blend_pose(lying, lying, 0.0)
	bounce.pos["pelvis"] = Vector2(-28, 160)
	bounce.rot["pelvis"] = -80.0
	return [[0.0, hurt_pose(1.0)], [0.3, buckle], [0.72, lying], [0.86, bounce], [1.2, lying]]

## World-space tip of the club (for hit detection).
func club_tip_global() -> Vector2:
	return bone_global("club", Vector2(0, -170))
