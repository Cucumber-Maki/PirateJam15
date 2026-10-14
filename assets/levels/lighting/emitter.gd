class_name Emitter

################################################################################

var enabled : bool;
var position : Vector2i;
var color : int;
var direction : Lighting.Direction;

################################################################################

func _init(_position : Vector2i, _color : int, _direction : Lighting.Direction) -> void:
	enabled = true;
	position = _position;
	color = _color;
	direction = _direction;
