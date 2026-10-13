extends GameSettableBase

################################################################################

# NOTE: This script pertains to overall game state.

################################################################################
# Config

const config_scene_main_menu : StringName = "res://scenes/main_menu/main_menu.tscn";

################################################################################	
# Settables

var active : bool = false; # Only true whilst gameplay is happening, needs to be set per scene.
var paused : bool : 
	get: return get_tree().paused;
	set(value): get_tree().paused = value;

################################################################################
# Gettables (internally managed!)

var debug_is_enabled : bool = false;

################################################################################
# Functions

@onready var _change_scene_file : StringName = get_tree().current_scene.scene_file_path;
func scene_change(scenePath : StringName) -> void:
	GameInput.active = false;
	_change_scene_file = scenePath;
	get_tree().call_deferred("change_scene_to_file", scenePath);
	
func scene_reset() -> void:
	get_tree().call_deferred("reload_current_scene")

func game_exit_to_menu() -> void:
	scene_change(config_scene_main_menu);
	
func game_restart() -> void:
	_state_reset();
	scene_change(ProjectSettings.get_setting("application/run/main_scene"));
	
func game_exit(exitCode : int = 0) -> void:
	get_tree().quit(exitCode);

################################################################################
# Internal

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	debug_is_enabled = OS.is_debug_build();
	get_tree().scene_changed.connect(_scene_changed);

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("game_fullscreen")):
		if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if (Input.is_action_just_pressed("game_debugMode")):
		_set_property("debug_is_enabled", !debug_is_enabled);

func _scene_changed() -> void:
	if (_change_scene_file != get_tree().current_scene.scene_file_path):
		Console.warning("It's recommended to change scene via GameState.scene_change(...) as unexpected state may occur");
		_change_scene_file = get_tree().current_scene.scene_file_path;
	active = false;
	paused = false;
	
func _state_reset() -> void:
	var defaultProperties : GameState = self.get_script().new();
	defaultProperties._ready();
	for rawProperty : Dictionary in self.get_script().get_script_property_list():
		var property : String = rawProperty.get("name");
		if (self.get(property) != defaultProperties.get(property)):
			self.set(property, defaultProperties.get(property));
