tool
extends Node
class_name WorldGen


export(bool) var regenerate = false setget set_regenerate
func set_regenerate(val):
	randomize()
	generate(true)


export(int, 64, 512) var size: int = 128 setget set_size
func set_size(val: int) -> void:
	size = val
	generate()


export(int, 1, 100) var period: int = 30 setget set_period
func set_period(val: int) -> void:
	period = val
	generate()


export(float, 0.0, 1.0) var persistence: float = 0.7 setget set_persistence
func set_persistence(val: float) -> void:
	persistence = val
	generate()


export(float, 0.0, 1.0) var water_coverage: float = 0.7 setget set_water_coverage
func set_water_coverage(val: float) -> void:
	water_coverage = val
	generate()


export(float, 0.5, 4.0) var coast: float = 1.0 setget set_coast
func set_coast(val: float) -> void:
	coast = val
	generate()


export(float, 0.0, 0.18) var midlands: float = 0.0 setget set_midlands
func set_midlands(val: float) -> void:
	midlands = val
	generate()


var world: WorldController
var coverage_bins: int = 1024
var noise: OpenSimplexNoise
var noise_image: Image


func _ready() -> void:
	generate(true)


func normalize_surface(val: float, level: float) -> float:
	var n: float = val - level
	
	if val <= level: #water
		return n / (level + 1)
	else: #land
		var v: float = n / (1 - level)
		
		if coast != 1:
			v = pow(v, coast) #apply coast size scaling
		
		if midlands != 0:
			v = v + midlands * sin(2 * PI * v)
		
		return v


func fix_water_level() -> void:
	var x: int
	var y: int
	var map: WorldMap = world.map
	
	var bins := PoolIntArray()
	bins.resize(coverage_bins)
	
	var i: int = 0
	while i < coverage_bins:
		bins[i] = 0
		i += 1
	
	y = 0
	while y < size:
		x = 0
		while x < size:
			var v: float = map.surface_value_at(x, y)
			var bi: int = int((v + 1.0) * coverage_bins / 2.0)
			if bi == coverage_bins:
				bi -= 1
			
			bins[bi] += 1
			
			x += 1
		y += 1
	
	#search for the height value that gives us the desired water coverage
	var coverage_sum: int = 0
	var coverage_target: int = int(round(water_coverage * size * size))
	
	i = 0
	while coverage_sum < coverage_target && i < coverage_bins:
		coverage_sum += bins[i]
		
		i += 1
		
	var water_level = (1.0 * i / coverage_bins) * 2 - 1
	
	#rescale values so that water is [-1, 0) and land is [0, 1]
	y = 0
	while y < size:
		x = 0
		while x < size:
			var v: float = map.surface_value_at(x, y)
			v = normalize_surface(v, water_level)
			map.surface_set_at(x, y, v)
			
			x += 1
		y += 1
	
	world.world_updated()


func generate(new_seed: bool = false) -> void:
	if !world:
		world = get_node("../World") as WorldController
	
	if !world:
		return
	
	var map: WorldMap = world.map
	
	if !map:
		return
	
	var x: int
	var y: int
	
	if !noise:
		noise = OpenSimplexNoise.new()
		noise.octaves = 4
		new_seed = true
	
	noise.period = period
	noise.persistence = persistence
	
	#only regenerate base noise image if randomizing map
	if new_seed || !noise_image:
		noise.seed = randi()
	
	noise_image = noise.get_seamless_image(size)
	
	var noise_min: float = 1.0
	var noise_max: float = 0.0
	
	noise_image.lock()
	
	#rescale noise output to use full [0, 1] range
	#OpenSimplexNoise only generates ~50% of the range
	
	#first, find min/max values
	y = 0
	while y < size:
		x = 0
		while x < size:
			var v: float = noise_image.get_pixel(x, y).r
			
			if v < noise_min:
				noise_min = v
			
			if v > noise_max:
				noise_max = v
			
			x += 1
		y += 1
		
		#apply scaling to noise image
		var d: float = noise_max - noise_min
		y = 0
		while y < size:
			x = 0
			while x < size:
				var v: float = noise_image.get_pixel(x, y).r
				
				v = (v - noise_min) / d
				
				noise_image.set_pixel(x, y, Color(v, v, v))
				
				x += 1
			y += 1
		#done rescaling
	
	map.surface_clear(size)
	
	y = 0
	while y < size:
		x = 0
		while x < size:
			var v: float = noise_image.get_pixel(x, y).r
			v = v * 2.0 - 1.0 #scale from image's [0, 1] range to map's [-1, 1] range
			map.surface_set_at(x, y, v)
			x += 1
		y += 1
	
	noise_image.unlock()
	
	#smooth poles
	y = 0
	var p: int = int(round(1.0 * size / 16))
	while y < p:
		x = 0
		var f: float = 1.0 * y / p
		while x < size:
			var v: float = map.surface_value_at(x, y)
			v *= f
			map.surface_set_at(x, y, v)
			
			v = map.surface_value_at(x, size - y - 1)
			v *= f
			map.surface_set_at(x, size - y - 1, v)
			
			x += 1
		y += 1
	
	fix_water_level()