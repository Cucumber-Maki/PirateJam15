class_name LightData
var color : int;
var data : Array[LightingInformation];

func _init() -> void:
	data = [
		LightingInformation.new(Lighting.Direction.Direction_Up),
		LightingInformation.new(Lighting.Direction.Direction_Right),
		LightingInformation.new(Lighting.Direction.Direction_Down),
		LightingInformation.new(Lighting.Direction.Direction_Left),
	];
	color = 0;
	
func calculate_total_color() -> void:
	color = 0;
	var shadow_color : int = 0;
	for lighting_info : LightingInformation in data:
		if (lighting_info.is_input): 
			if (lighting_info.color & Lighting.LIGHTING_VALUE_SHADOW_MASK): shadow_color |= lighting_info.color;
			else: color |= lighting_info.color & Lighting.LIGHTING_VALUE_COLOR_MASK;
			
	if (color == 0 && shadow_color != 0):
		color = shadow_color;
