extends Node2D
## Child of a visible branch socket; no independent world starting position.
var length_world := 250.0
var inherited_scale := 1.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var inv := 1.0/inherited_scale
	var path := PackedVector2Array()
	for i in 33:
		var t := i/32.0
		path.append(Vector2(sin(t*PI*2.2)*5*t, t*length_world)*inv)
	draw_polyline(path,Color("42552c"),6*inv,true)
	draw_polyline(path,Color("82933b"),3*inv,true)
	# Small loop visibly wraps the branch; leaves are tiny relative to the128-unit ruler.
	draw_arc(Vector2(0,-2)*inv,7*inv,-0.5,PI*1.45,16,Color("5a6a30"),3*inv,true)
	for i in range(1,int(length_world/65.0)+1):
		var y := i*57.0
		if y > length_world-20: continue
		var side := 1.0 if i%2 else -1.0
		var x := sin(y/length_world*PI*2.2)*5*y/length_world
		var leaf := PackedVector2Array([Vector2(x,y),Vector2(x+side*6,y-5),Vector2(x+side*13,y-3),Vector2(x+side*10,y+4),Vector2(x+side*3,y+6)])
		for j in leaf.size(): leaf[j] *= inv
		draw_colored_polygon(leaf,Color("789b38") if i%2 else Color("4d824b"))
