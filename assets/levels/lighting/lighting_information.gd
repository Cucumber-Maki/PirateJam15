class_name LightingInformation

################################################################################

var is_input : bool;
var color : int;
var direction : Lighting.Direction;

################################################################################

func _init(p_direction : Lighting.Direction) -> void:
	is_input = false;
	color = 0;
	direction = p_direction;
