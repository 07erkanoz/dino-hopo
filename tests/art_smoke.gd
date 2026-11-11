extends SceneTree
const Art = preload("res://scripts/art.gd")

func _initialize() -> void:
	var approval: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/characters/approved-sha256.json"))
	for path in approval:
		assert(FileAccess.get_sha256("res://" + path) == approval[path], "Approved hero artwork changed")
	var count := 0
	for entry in [["heroes", 16], ["props", 6], ["creatures", 6], ["equipment", 4], ["jungle", 6], ["habitat", 4]]:
		for i in entry[1]:
			var sprite := Art.sprite(entry[0], i)
			assert(sprite.region.size.x > 0 and sprite.region.size.y > 0)
			assert(Rect2(Vector2.ZERO, sprite.atlas.get_size()).encloses(sprite.region))
			var source := sprite.atlas.get_image()
			assert(source.has_mipmaps() == false)
			assert(source.get_format() == Image.FORMAT_RGBA8)
			var opaque_samples := 0
			var transparent_samples := 0
			for x in range(int(sprite.region.position.x), int(sprite.region.end.x), 12):
				for y in range(int(sprite.region.position.y), int(sprite.region.end.y), 12):
					var alpha := source.get_pixel(x, y).a
					if alpha > 0.5: opaque_samples += 1
					if alpha < 0.02: transparent_samples += 1
			assert(opaque_samples > 5, "Sprite region is empty")
			assert(transparent_samples > 0, "Sprite has no transparent surround")
			count += 1
	print("PASS: %d sprite regions inside source bounds, RGBA, visible artwork, transparent surround" % count)
	quit(0)
