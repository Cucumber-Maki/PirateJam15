class_name LightButton

################################################################################

var position : Vector2i;
var color : int;
var lit : bool;

################################################################################

func _init(p_position : Vector2i, p_color : int) -> void:
	position = p_position;
	color = p_color;
	lit = false;
