tool
extends Node2D
class_name WorldController

var map: WorldMap


func _ready() -> void:
	map = WorldMap.new()


func world_updated() -> void:
	render_world()


func render_world() -> void:
	($Layers/Surface as SurfaceLayer).render(map)