extends RefCounted
## Read-only regions over original drawings; image source files remain intact.
static var data: Dictionary = {}
static var textures: Dictionary = {}

static func sprite(group: String, index: int) -> AtlasTexture:
	if data.is_empty():
		data = JSON.parse_string(FileAccess.get_file_as_string("res://art/atlas-regions.json"))
	var key := "%s/%d" % [group, index]
	if not textures.has(key):
		var entry: Dictionary = data[group]
		var box: Array = entry.regions[index]
		var texture := AtlasTexture.new()
		texture.atlas = load(entry.path)
		texture.region = Rect2(box[0], box[1], box[2], box[3])
		texture.filter_clip = true
		textures[key] = texture
	return textures[key]
