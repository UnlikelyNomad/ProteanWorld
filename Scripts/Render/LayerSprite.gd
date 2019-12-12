tool
extends Sprite
class_name LayerSprite

var _layer_image: Image
var _layer_texture: ImageTexture


func _render(map: WorldMap) -> void: #virtual
	pass


func render(map: WorldMap) -> void:
	if !_layer_image:
		_layer_image = Image.new()
		
	_layer_image.create(map.size, map.size, false, Image.FORMAT_RGBA8)
	
	if !_layer_texture:
		_layer_texture = ImageTexture.new()
	
	_layer_image.lock()
	
	_render(map)
	
	_layer_image.unlock()
	
	_layer_texture.create_from_image(_layer_image, 0)
	self.texture = _layer_texture
