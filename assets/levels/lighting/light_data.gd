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
	
func calculateTotalColor() -> void:
	color = 0;
	var shadowColor : int = 0;
	for lightingInfo : LightingInformation in data:
		if (lightingInfo.isInput): 
			if (lightingInfo.color & Lighting.LightingValueShadowMask): shadowColor |= lightingInfo.color;
			else: color |= lightingInfo.color & Lighting.LightingValueColorMask;;
			
	if (color == 0 && shadowColor != 0):
		color = shadowColor;
