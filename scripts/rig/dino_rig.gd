extends "res://scripts/rig/rig.gd"
## Small ceratopsian (art faces left). Quadruped diagonal gait with IK-planted
## feet; the walk/charge cycles are advanced by distance travelled.

const GROUND_Y := 323.0
const ANKLE_Y := 291.0
const HALF_STEP := 28.0
const CHARGE_HALF_STEP := 40.0
const CHARGE_STANCE := 0.4
const STRIDE := HALF_STEP * 4.0                          # art px per walk cycle
const CHARGE_STRIDE := CHARGE_HALF_STEP * 2.0 / CHARGE_STANCE
const STATES := ["idle", "walk", "windup", "charge", "hurt", "die"]
const HURT_LENGTH := 0.43
const LEGS := [
	["front_near_upper", "front_near_lower", "front_near_foot", 0.0, 1.0],
	["hind_far_upper", "hind_far_lower", "hind_far_foot", 0.0, -1.0],
	["front_far_upper", "front_far_lower", "front_far_foot", 0.5, 1.0],
	["hind_near_upper", "hind_near_lower", "hind_near_foot", 0.5, -1.0],
]
var feet: Dictionary = {}

func _init() -> void:
	name = "DinoRig"

func _ready() -> void:
	build("enemy_dino", Vector2(335, GROUND_Y))
	for leg in LEGS: feet[leg[2]] = rest_point(leg[2])
	add_sampled("idle", 2.2, true, 22, idle_pose)
	add_sampled("walk", 1.0, true, 32, walk_pose)
	add_sampled("charge", 1.0, true, 32, charge_pose)
	add_animation("windup", 0.7, false, [[0.0, idle_pose(0.0)], [0.18, windup_pose(1.0, 0.0)], [0.36, windup_pose(1.0, 1.0)], [0.52, windup_pose(1.0, 0.0)], [0.7, windup_pose(1.1, 1.0)]])
	add_animation("hurt", HURT_LENGTH, false, [[0.0, idle_pose(0.0)], [0.05, hurt_pose(1.0)], [0.18, hurt_pose(0.75)], [0.32, hurt_pose(0.35)], [HURT_LENGTH, hurt_pose(0.1)]])
	add_animation("die", 1.1, false, die_keys())
	add_animation("RESET", 0.01, false, [[0.0, pose()]])
	build_tree(STATES, "idle", ["walk", "charge"], 0.15, {"hurt": 0.04, "die": 0.06, "windup": 0.1})

func place_feet(p: Dictionary, offsets: Dictionary, angles := {}) -> Dictionary:
	for leg in LEGS:
		var target: Vector2 = feet[leg[2]] + offsets.get(leg[2], Vector2.ZERO)
		solve_leg(p, leg[0], leg[1], leg[2], target, leg[4], angles.get(leg[2], 0.0))
	return p

func idle_pose(phase: float) -> Dictionary:
	var b := sin(phase * TAU)
	var p := pose({"neck": 2.0 * b, "head": -3.0 * sin(phase * TAU - 0.8), "tail": 4.0 * sin(phase * TAU - 1.2), "torso": 0.6 * b},
		{"torso": Vector2(0, 2.0 + 1.5 * b)})
	return place_feet(p, {})

func gait_offset(phase: float, half: float, stance: float, lift: float) -> Vector2:
	phase = fposmod(phase, 1.0)
	if phase < stance:
		return Vector2(-half * (1.0 - 2.0 * phase / stance), 0.0)
	var s := (phase - stance) / (1.0 - stance)
	var e := s * s * (3.0 - 2.0 * s)
	return Vector2(half - 2.0 * half * e, -lift * sin(PI * s))

func walk_pose(phase: float) -> Dictionary:
	var offsets := {}
	for leg in LEGS: offsets[leg[2]] = gait_offset(phase + leg[3], HALF_STEP, 0.5, 14.0)
	var bob := cos(phase * TAU * 2.0)
	var p := pose({"neck": 3.0 * bob, "head": -2.0 * sin(phase * TAU * 2.0 - 1.0), "tail": 7.0 * sin(phase * TAU - 1.6), "torso": 1.2 * sin(phase * TAU)},
		{"torso": Vector2(0, 3.0 + 2.5 * bob)})
	return place_feet(p, offsets)

func charge_pose(phase: float) -> Dictionary:
	var offsets := {}
	for leg in LEGS: offsets[leg[2]] = gait_offset(phase + leg[3] * 0.9, CHARGE_HALF_STEP, CHARGE_STANCE, 22.0)
	var bob := cos(phase * TAU * 2.0)
	var p := pose({"neck": -10.0 + 3.0 * bob, "head": -12.0 - 3.0 * bob, "tail": -8.0 + 10.0 * sin(phase * TAU - 1.4), "torso": 3.0 + 2.0 * sin(phase * TAU)},
		{"torso": Vector2(0, 7.0 + 5.0 * bob)})
	return place_feet(p, offsets)

## Head lowered, front foot scraping: the telegraph before a charge.
func windup_pose(amount: float, scrape: float) -> Dictionary:
	var p := pose({"neck": -14.0 * amount, "head": -18.0 * amount, "tail": 14.0 * amount, "torso": -3.0 * amount},
		{"torso": Vector2(6.0 * amount, 9.0 * amount)})
	return place_feet(p, {"front_near_foot": Vector2(18.0 * scrape, -10.0 * scrape)})

func hurt_pose(amount: float) -> Dictionary:
	var p := pose({"neck": 18.0 * amount, "head": 24.0 * amount, "tail": -16.0 * amount, "torso": 5.0 * amount},
		{"torso": Vector2(10.0 * amount, 6.0 * amount)})
	return place_feet(p, {"front_near_foot": Vector2(0, -14.0 * amount), "front_far_foot": Vector2(6.0, -6.0 * amount)})

func die_keys() -> Array:
	var stagger := hurt_pose(1.0)
	var down := pose({"torso": -4.0, "neck": -24.0, "head": -20.0, "tail": 14.0}, {"torso": Vector2(0, 62)})
	place_feet(down, {"front_near_foot": Vector2(-34, 0), "front_far_foot": Vector2(-24, 0), "hind_near_foot": Vector2(36, 0), "hind_far_foot": Vector2(26, 0)})
	var settle := blend_pose(down, down, 0.0)
	settle.pos["torso"] = Vector2(0, 54)
	return [[0.0, stagger], [0.3, hurt_pose(0.6)], [0.75, down], [0.9, settle], [1.1, down]]
