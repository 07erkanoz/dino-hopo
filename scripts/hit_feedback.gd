extends Node2D
const Art = preload("res://scripts/art.gd")
var age := 0.0
var side := 1.0
var sound_enabled := true
var variant := 0

static func play_sound(parent: Node, name: String, pitch: float = 1.0, volume: float = -12) -> void:
	var sound := AudioStreamPlayer.new()
	sound.stream = load("res://audio/sfx/" + name + ".wav")
	sound.pitch_scale = pitch
	sound.volume_db = volume
	parent.add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()

func _ready() -> void:
	z_index = 6
	if sound_enabled:
		play_sound(self, "wood_hit", 0.96 + variant % 3 * 0.05, -9)
		play_sound(self, "recoil_a" if variant % 2 == 0 else "recoil_b", 0.94 + variant % 3 * 0.05, -13)

func _process(delta: float) -> void:
	age += delta
	if age >= 0.65:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	if age < 0.25:
		var t := age / 0.25
		var size := Vector2(90, 68) * lerpf(0.45, 1.3, t)
		draw_texture_rect(Art.sprite("equipment", 2), Rect2(-size / 2, size), false, Color(1,1,1,1-t))
	for i in 5:
		var t := clampf(age / 0.42, 0, 1)
		var angle := -2.2 + i * 0.5
		var offset := Vector2(cos(angle) * side, sin(angle)) * (18 + t * 60) + Vector2(0, t*t*22)
		var size := Vector2.ONE * lerpf(18, 8, t)
		draw_texture_rect(Art.sprite("equipment", 3), Rect2(offset - size / 2, size), false, Color(1,1,1,1-t))
