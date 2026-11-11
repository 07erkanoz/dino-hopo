extends Sprite2D
var phase := 0.0
var wind := 0.02
var base_rotation := 0.0

func _process(_delta: float) -> void:
	rotation = base_rotation + sin(Time.get_ticks_msec() / 1500.0 + phase) * wind
