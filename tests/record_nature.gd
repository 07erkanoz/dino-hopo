extends SceneTree
## Nature-only camera inspection. Does not create or move gameplay actors.
var scene: Node2D
var elapsed := 0.0

func _initialize() -> void:
	call_deferred("begin")

func begin() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	scene = load("res://scenes/nature_workspace.tscn").instantiate()
	root.add_child(scene)
	scene.overlay.visible = false
	scene.camera.zoom = Vector2.ONE*.72

func _process(delta: float) -> bool:
	if not is_instance_valid(scene): return false
	elapsed += delta
	if elapsed < 1:
		scene.camera.position = Vector2(512,780)
	elif elapsed < 5:
		var t := smoothstep(1,5,elapsed)
		scene.camera.position = Vector2(512,780).lerp(Vector2(1650,680),t)
	elif elapsed < 6:
		scene.camera.position = Vector2(1650,680)
	else:
		var t := smoothstep(6,10,elapsed)
		scene.camera.position = Vector2(1650,680).lerp(Vector2(3584,800),t)
	return false
