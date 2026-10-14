class_name LightButton

################################################################################

var position : Vector2i;
var color : int;
var lit : bool;

################################################################################

func _init(_position : Vector2i, _color : int) -> void:
	position = _position;
	color = _color;
	lit = false;
