tool
extends LayerSprite
class_name SurfaceLayer


func surface_color(val: float) -> Color:
	var r: float
	var g: float
	var b: float
	
	if val < 0: #water
		r = 0
		g = (val + 1) * 0.25
		b = (val + 2.0) / 2.0
	else: #land
		var v2 := pow(val, 2)
		r = (5 * v2 - 4 * val + 1) / 2
		g = v2 / 2.0 + 0.5
		b = v2
	
	return Color(r, g, b, 1.0)


func _render(map: WorldMap) -> void:
	var y := 0
	while y < map.size:
		var x := 0
		while x < map.size:
			_layer_image.set_pixel(x, y, surface_color(map.surface_value_at(x, y)))
			x += 1
		y += 1