extends CanvasLayer

var gen: WorldGen


func _ready() -> void:
	gen = get_node("../WorldGen") as WorldGen


func period_changed(value: int) -> void:
	gen.period = value


func water_coverage_changed(value: float) -> void:
	gen.water_coverage = value

func persistence_changed(value: float) -> void:
	gen.persistence = value


func coasts_changed(value: float) -> void:
	gen.coast = value


func midlands_changed(value: float) -> void:
	gen.midlands = value


func randomize_clicked() -> void:
	gen.generate(true)
