extends Node2D
const Plan = preload("res://scripts/nature_plan.gd")
const Assets = preload("res://scripts/nature_assets.gd")
const Vine = preload("res://scripts/nature_vine.gd")
var data: Dictionary
var support_trees: Dictionary = {}
var vine_nodes: Dictionary = {}
var far_layers: Array[Parallax2D] = []
var decoration_count := 0

func _ready() -> void:
	Assets.setup()
	build_backdrop()
	build_ground()
	build_trees()
	build_plants()
	queue_redraw()

func polygon(points: Array, color: Color, z: int, rounding: float = 0) -> Polygon2D:
	var node := Polygon2D.new()
	var shape := PackedVector2Array()
	for p in points: shape.append(Vector2(p[0],p[1]))
	node.polygon = rounded(points,rounding) if rounding > 0 else shape
	node.color = color
	node.z_index = z
	add_child(node)
	return node

func rounded(points: Array, radius: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for i in points.size():
		var a := Vector2(points[(i-1+points.size())%points.size()][0],points[(i-1+points.size())%points.size()][1])
		var p := Vector2(points[i][0],points[i][1])
		var b := Vector2(points[(i+1)%points.size()][0],points[(i+1)%points.size()][1])
		var start := p+(a-p).normalized()*minf(radius,p.distance_to(a)*.25)
		var end := p+(b-p).normalized()*minf(radius,p.distance_to(b)*.25)
		for j in 7:
			var t := j/6.0
			result.append(start*(1-t)*(1-t)+p*2*t*(1-t)+end*t*t)
	return result

func water_curve(points: Array) -> PackedVector2Array:
	var curve := Curve2D.new()
	for i in points.size():
		var point := Vector2(points[i][0],points[i][1])
		var prev := Vector2(points[maxi(0,i-1)][0],points[maxi(0,i-1)][1])
		var next := Vector2(points[mini(points.size()-1,i+1)][0],points[mini(points.size()-1,i+1)][1])
		var tangent := (next-prev)/6
		curve.add_point(point,-tangent,tangent)
	return curve.get_baked_points()

func build_backdrop() -> void:
	polygon([[-5000,-3000],[12000,-3000],[12000,5000],[-5000,5000]],Color("f5edc8"),-100)
	polygon([[-2000,1000],[0,930],[700,880],[1400,1000],[2200,940],[3000,900],[4000,980],[5000,900],[7000,980],[9000,900],[9000,2500],[-2000,2500]],Color("b9cd94"),-50)
	for depth_index in 2:
		var layer := Parallax2D.new()
		layer.scroll_scale = Vector2(0.22 if depth_index==0 else 0.5,1)
		layer.z_index = -45 if depth_index==0 else -35
		add_child(layer)
		far_layers.append(layer)
		for i in range(-2,13):
			var model_index := posmod(i+depth_index,2)
			var texture := Assets.sprite("trees",model_index)
			var model: Dictionary = Assets.style.trees.models[model_index]
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.centered = false
			sprite.offset = -Vector2(model.root_pixel[0],model.root_pixel[1])
			sprite.position = Vector2(i*(550 if depth_index==0 else 830)+depth_index*220,1010)
			var height := (420 if depth_index==0 else 530)+posmod(i*37,100)
			sprite.scale = Vector2.ONE*height/float(model.reference_height)
			var shader := Shader.new()
			shader.code = "shader_type canvas_item; uniform vec4 dark_color:source_color; uniform vec4 light_color:source_color;void fragment(){vec4 t=texture(TEXTURE,UV);float l=dot(t.rgb,vec3(.3,.59,.11));float b=floor(l*4.)/3.;COLOR=vec4(mix(dark_color.rgb,light_color.rgb,clamp(b,0.,1.)),t.a);}"
			var material := ShaderMaterial.new()
			material.shader = shader
			material.set_shader_parameter("dark_color",Color("739f87") if depth_index==0 else Color("508b71"))
			material.set_shader_parameter("light_color",Color("b8ce95") if depth_index==0 else Color("9ac070"))
			sprite.material = material
			layer.add_child(sprite)

func build_ground() -> void:
	var ground_points: Array = []
	for x in range(-2048,int(data.width)+2049,24): ground_points.append([x,Plan.surface_at(data,x)])
	ground_points.append([data.width+2048,2100])
	ground_points.append([-2048,2100])
	var soil := polygon(ground_points,Color.WHITE,-5)
	soil.texture = load(Assets.style.soil_path)
	var shader := Shader.new()
	shader.code = "shader_type canvas_item;varying vec2 world_uv;void vertex(){world_uv=VERTEX/720.;}void fragment(){vec2 q=abs(fract(world_uv*.5)*2.-1.);vec4 t=texture(TEXTURE,q);COLOR=vec4(t.rgb,1.0);}"
	var material := ShaderMaterial.new()
	material.shader = shader
	soil.material = material
	polygon(data.water.waterfall.headland,Color("b8783e"),-4,65)
	polygon([[3320,600],[3450,660],[3500,988],[3320,1040]],Color("a56a3c"),-3,35)
	polygon([[3450,660],[3650,630],[3610,970],[3510,988]],Color("c9884b"),-3,40)
	polygon([[3650,635],[3770,660],[3770,1008],[3620,980]],Color("9b603b"),-3,35)
	# Cave void is part of the terrain section; no actor/quest/obstacle is spawned.
	var cave: Array = data.cavern.bounds
	polygon([[cave[0]-65,cave[1]+70],[cave[0]+65,cave[1]],[cave[0]+cave[2]-60,cave[1]+5],[cave[0]+cave[2]+50,cave[1]+95],[cave[0]+cave[2],cave[1]+cave[3]],[cave[0],cave[1]+cave[3]]],Color("4b392d"),-3,65)

func tree_sprite(definition: Dictionary, parent: Node, z: int) -> Sprite2D:
	var model: Dictionary = Assets.style.trees.models[definition.model]
	var sprite := Sprite2D.new()
	sprite.texture = Assets.sprite("trees",definition.model)
	sprite.centered = false
	sprite.offset = -Vector2(model.root_pixel[0],model.root_pixel[1])
	sprite.position = Plan.tree_root(data,definition)
	sprite.scale = Vector2.ONE*float(definition.height)/float(model.reference_height)
	sprite.z_index = z
	parent.add_child(sprite)
	return sprite

func build_trees() -> void:
	for tree in data.trees:
		var sprite := tree_sprite(tree,self,1)
		support_trees[tree.id] = sprite
		var model: Dictionary = Assets.style.trees.models[tree.model]
		for branch in tree.branches:
			var socket := Marker2D.new()
			socket.name = branch.id
			socket.position = Vector2(model.branch_pixel[0]-model.root_pixel[0],model.branch_pixel[1]-model.root_pixel[1])
			sprite.add_child(socket)
			for definition in data.vines:
				if definition.tree_id != tree.id or definition.branch_id != branch.id: continue
				var vine := Vine.new()
				vine.length_world = definition.length
				vine.inherited_scale = sprite.scale.x
				socket.add_child(vine)
				vine_nodes[definition.id] = vine
	for definition in data.decor_trees:
		tree_sprite(definition,self,-1)

func prop(index: int, foot: Vector2, height: float, z: int = 2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = Assets.sprite("props",index)
	sprite.position = foot
	sprite.offset.y = -sprite.texture.get_height()/2
	sprite.scale = Vector2.ONE*height/sprite.texture.get_height()
	sprite.z_index = z
	sprite.set_meta("prop_index",index)
	sprite.set_meta("height_units",height)
	add_child(sprite)
	decoration_count += 1
	return sprite

func build_plants() -> void:
	var river: Dictionary = data.water.river
	for i in range(1,27):
		var x := float(i*226+posmod(i*41,80))
		if x > data.width or (x > river.left-25 and x < river.right+25): continue
		var y := Plan.surface_at(data,x)
		prop(2,Vector2(x,y+2),22+posmod(i*7,13))
		if i%2==0: prop(1,Vector2(x+70,Plan.surface_at(data,x+70)+3),48+posmod(i*11,18))
		if i%4==0: prop(5,Vector2(x-80,Plan.surface_at(data,x-80)+3),62)
		if i%5==0: prop(3,Vector2(x+110,Plan.surface_at(data,x+110)+4),58+posmod(i*13,30),0)
	prop(1,Vector2(3380,574),58)
	prop(2,Vector2(3610,603),28)
	var cave: Array = data.cavern.bounds
	prop(4,Vector2(cave[0]+90,cave[1]+cave[3]+8),255,1)

func _draw() -> void:
	if data.is_empty(): return
	var edge := PackedVector2Array()
	for x in range(-2048,int(data.width)+2049,12): edge.append(Vector2(x,Plan.surface_at(data,x)))
	draw_polyline(edge,Color("415e34"),17,true)
	var light_edge := PackedVector2Array()
	for point in edge: light_edge.append(point-Vector2(0,4))
	draw_polyline(light_edge,Color("91b843"),11,true)
	# Small blades follow the same sampled terrain; no rectangular grass stamps.
	for x in range(-2048,int(data.width)+2049,20):
		var y := Plan.surface_at(data,x)
		var height := 7+posmod(int(x/20)*5,7)
		draw_colored_polygon(PackedVector2Array([Vector2(x-4,y),Vector2(x-5,y-height),Vector2(x+1,y-3),Vector2(x+5,y-height+3),Vector2(x+5,y+2)]),Color("789d39"))
	var river: Dictionary = data.water.river
	var river_shape := PackedVector2Array([Vector2(river.left,river.surface_y),Vector2(river.right,river.surface_y),Vector2(river.right-100,river.bottom_y),Vector2(river.left+120,river.bottom_y)])
	draw_colored_polygon(river_shape,Color("459e9b"))
	for i in 9:
		var x: float = river.left+65+i*62
		var y: float = river.surface_y+18+(i%3)*17
		draw_line(Vector2(x,y),Vector2(x+35,y),Color("b4e5cf"),3,true)
	var falls: Dictionary = data.water.waterfall
	var stream := PackedVector2Array()
	for point in falls.feed_stream: stream.append(Vector2(point[0],point[1]))
	stream.append(Vector2(falls.lip[0],falls.lip[1]))
	draw_polyline(stream,Color("57b5ac"),26,true)
	var lip := Vector2(falls.lip[0],falls.lip[1])
	var pool := Vector2(falls.pool[0],falls.pool[1])
	draw_colored_polygon(PackedVector2Array([lip-Vector2(30,0),lip+Vector2(30,0),pool+Vector2(52,0),pool-Vector2(52,0)]),Color("61bdb3"))
	for i in 5:
		var x := lip.x-24+i*12
		draw_line(Vector2(x,lip.y+12),Vector2(x+6,pool.y-8),Color("c5edda"),3,true)
	for i in 7: draw_circle(pool+Vector2((i-3)*17,-absf(i-3)*3),16,Color("d2efda"))
	var outlet := water_curve(falls.outlet)
	draw_polyline(outlet,Color("397f79"),31,true)
	draw_polyline(outlet,Color("57aaa1"),24,true)
	for i in range(0,outlet.size(),18):
		draw_circle(outlet[i],12,Color("57aaa1"))
		draw_line(outlet[i]-Vector2(7,2),outlet[i]+Vector2(10,2),Color("b4e5cf"),2,true)
