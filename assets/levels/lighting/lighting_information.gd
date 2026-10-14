class_name LightingInformation

################################################################################

var isInput : bool;
var color : int;
var direction : Lighting.Direction;

################################################################################

func _init(_direction : Lighting.Direction) -> void:
	isInput = false;
	color = 0;
	direction = _direction;
