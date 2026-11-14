extends SceneTree
## Rig contact sheet: every animation of a Skeleton2D rig sampled at 6 points.
## Run through tools/capture.sh (needs a renderer):
## godot --path . --script tests/capture_rig_sheet.gd -- cagan|dino|ptero res://ciktilar/ekran/x.png

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	var which := args[0] if args.size() > 0 else "cagan"
	var out := args[1] if args.size() > 1 else "res://ciktilar/ekran/rig-%s.png" % which
	var scripts := {"cagan": "res://scripts/rig/cagan_rig.gd", "dino": "res://scripts/rig/dino_rig.gd", "ptero": "res://scripts/rig/ptero_rig.gd"}
	var script: GDScript = load(scripts[which])
	var probe = script.new()
	var states: Array = probe.STATES
	probe.free()
	var view := SubViewport.new()
	view.size = Vector2i(1360, 160 * states.size() + 20)
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var bg := ColorRect.new()
	bg.color = Color(0.85, 0.9, 0.85)
	bg.size = Vector2(view.size)
	view.add_child(bg)
	var cols := 6
	for row in states.size():
		var label := Label.new()
		label.text = states[row]
		label.position = Vector2(8, row * 160 + 10)
		label.add_theme_color_override("font_color", Color.BLACK)
		view.add_child(label)
		for col in cols:
			var rig = script.new()
			rig.position = Vector2(150 + col * 210, row * 160 + 150)
			rig.scale = Vector2.ONE * (0.3 if which == "cagan" else 0.35)
			view.add_child(rig)
			var line := Line2D.new()
			line.points = PackedVector2Array([rig.position + Vector2(-90, 0), rig.position + Vector2(90, 0)])
			line.width = 1
			line.default_color = Color(0.3, 0.2, 0.1)
			view.add_child(line)
			rig.tree.active = false
			var anim: Animation = rig.library.get_animation(states[row])
			rig.player.play(states[row])
			rig.player.seek(anim.length * col / float(cols - 1) * (0.999 if anim.loop_mode == Animation.LOOP_NONE else (cols - 1.0) / cols), true)
			rig.player.pause()
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png(out)
	print("SAVED ", out.get_file())
	quit()
