extends "res://scripts/rig/rig.gd"
## Small pterosaur (art faces left): two-segment wings with follow-through
## (the outer wing lags the upper wing), dangling legs and tail drag.

const STATES := ["fly", "swoop", "hurt", "die"]
const HURT_LENGTH := 0.43

func _init() -> void:
	name = "PteroRig"

func _ready() -> void:
	build("enemy_second", Vector2(250, 215))
	add_sampled("fly", 0.62, true, 24, fly_pose)
	add_animation("swoop", 0.9, false, [[0.0, fly_pose(0.0)], [0.2, swoop_pose(1.0)], [0.65, swoop_pose(1.0)], [0.9, fly_pose(0.25)]])
	add_animation("hurt", HURT_LENGTH, false, [[0.0, fly_pose(0.0)], [0.05, hurt_pose(1.0)], [0.2, hurt_pose(0.7)], [0.32, hurt_pose(0.35)], [HURT_LENGTH, hurt_pose(0.1)]])
	add_animation("die", 1.0, false, [[0.0, hurt_pose(1.0)], [0.4, limp_pose(0.6)], [1.0, limp_pose(1.0)]])
	add_animation("RESET", 0.01, false, [[0.0, pose()]])
	build_tree(STATES, "fly", [], 0.12, {"hurt": 0.04, "die": 0.06})

## Wing beat: downstroke is faster than the upstroke; outer segment lags.
func fly_pose(phase: float) -> Dictionary:
	var beat := sin(phase * TAU)
	var lag := sin(phase * TAU - 0.9)
	return pose({
		"wing_near_upper": -24.0 * beat, "wing_near_outer": -14.0 * lag,
		"wing_far_upper": -20.0 * beat, "wing_far_outer": -12.0 * lag,
		"head": 4.0 * sin(phase * TAU + 0.6), "tail": 8.0 * sin(phase * TAU - 1.8),
		"leg_near": 10.0 * sin(phase * TAU - 2.0), "leg_far": 10.0 * sin(phase * TAU - 2.3), "torso": 3.0 * beat,
	}, {"torso": Vector2(0, 10.0 * beat)})

func swoop_pose(amount: float) -> Dictionary:
	return pose({"wing_near_upper": 34.0 * amount, "wing_near_outer": 40.0 * amount, "wing_far_upper": 28.0 * amount, "wing_far_outer": 32.0 * amount,
		"head": 18.0 * amount, "tail": -12.0 * amount, "leg_near": -30.0 * amount, "leg_far": -26.0 * amount, "torso": -18.0 * amount})

func hurt_pose(amount: float) -> Dictionary:
	return pose({"wing_near_upper": -50.0 * amount, "wing_near_outer": 30.0 * amount, "wing_far_upper": -40.0 * amount, "wing_far_outer": 26.0 * amount,
		"head": -30.0 * amount, "tail": 20.0 * amount, "leg_near": 30.0 * amount, "leg_far": 26.0 * amount, "torso": 14.0 * amount}, {"torso": Vector2(14.0 * amount, -6.0 * amount)})

func limp_pose(amount: float) -> Dictionary:
	return pose({"wing_near_upper": 60.0 * amount, "wing_near_outer": 50.0 * amount, "wing_far_upper": 50.0 * amount, "wing_far_outer": 40.0 * amount,
		"head": 50.0 * amount, "tail": 30.0 * amount, "leg_near": -20.0 * amount, "leg_far": -10.0 * amount, "torso": -60.0 * amount}, {"torso": Vector2(0, 30.0 * amount)})
