extends GameSaveableBase;

################################################################################

# NOTE: This script pertains to user settings that persists between game 
#		instances and should not be used for save-game specific data. 

################################################################################
	
var camera_mouse_sensitivity : float = 5.0;
var camera_analog_sensitivity : float = 5.0;
var camera_invert_x : bool = false;
var camera_invert_y : bool = false;

var volume_settings : Array[float] = []; # Automatically populates in _init.

################################################################################	

func get_file_location() -> String:
	return "config.txt"

################################################################################	

func _init() -> void:	
	for bus_index in AudioServer.bus_count:
		volume_settings.append(0.5);
		
func _ready() -> void:
	super();
	
	while (len(volume_settings) > AudioServer.bus_count):
		volume_settings.pop_back();
	bind_on_property_change("volume_settings",
		func(value : Array) -> void:
			for i in len(value):
				AudioServer.set_bus_volume_linear(i, value[i])
	)
