class_name Emitter

################################################################################

var enabled : bool;
var position : Vector2i;
var color : int;
var direction : Lighting.Direction;

################################################################################

func _init(p_position : Vector2i, p_color : int, p_direction : Lighting.Direction) -> void:
	enabled = true;
	position = p_position;
	color = p_color;
	direction = p_direction;
