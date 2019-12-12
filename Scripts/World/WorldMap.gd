tool
extends Reference
class_name WorldMap


var _surface: PoolRealArray = []
var size: int = 128
var atmo_layers: int = 10
var water_depth: int = 6 #number of simulation layers for deepest region of oceans
var land_height: int = 2 #height mountains can extend into atmosphere


func surface_value_at(x: int, y: int) -> float:
	return _surface[y * size + x]


func surface_clear(new_size: int) -> void:
	var n: int = new_size * new_size
	_surface.resize(n)
	size = new_size
	
	var i := 0
	while i < n:
		_surface.set(i, 0.0)
		
		i += 1


func surface_set_at(x: int, y: int, val: float) -> void:
	_surface.set(y * size + x, val)
