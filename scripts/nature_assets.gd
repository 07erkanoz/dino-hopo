extends RefCounted
static var style: Dictionary = {}
static var cached: Dictionary = {}

static func setup() -> void:
	if style.is_empty():
		style = JSON.parse_string(FileAccess.get_file_as_string("res://world/nature/style-01.json"))

static func sprite(group: String, index: int) -> AtlasTexture:
	setup()
	var key := "%s/%d" % [group,index]
	if not cached.has(key):
		var entry: Dictionary = style[group]
		var box: Array = entry.regions[index]
		var texture := AtlasTexture.new()
		texture.atlas = load(entry.path)
		texture.region = Rect2(box[0],box[1],box[2],box[3])
		texture.filter_clip = true
		cached[key] = texture
	return cached[key]
