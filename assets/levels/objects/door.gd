class_name Door

################################################################################

var position : Vector2i;
var color : int;
var open : bool;

################################################################################

func _init(_position : Vector2i, _color : int) -> void:
	position = _position;
	color = _color;
	open = false;
