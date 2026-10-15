extends GameSettableBase

################################################################################

# NOTE: This script pertains to both the readings and config of the the player 
# 		input, accessible globally throughout the game.

################################################################################
# Config

const config_capture_mouse : bool = true;
const _config_input_events_in_physics_process : bool = true;

################################################################################
# Settables

var active : bool = false : # Determines whether player input (non-mouse) should be captured or not.
	set(value):
		if (active == value): return;
		active = value;
		_update_mouse_visibility_state();

################################################################################
# Gettables (internally managed!)

var is_using_controller : bool = false : 
	set(value):
		if (is_using_controller == value): return;
		is_using_controller = value;
		_update_mouse_visibility_state();

################################################################################
# Functions

func is_mouse_visible() -> bool:
	return !((config_capture_mouse && active) || is_using_controller);
func is_mouse_locked() -> bool:
	return config_capture_mouse && active && !is_using_controller;

func get_player_move_input(p_angle : float = 0.0) -> Vector2:
	return Vector2(
		Input.get_axis("player_move_left", "player_move_right"),
		Input.get_axis("player_move_forward", "player_move_backward")
	).rotated(p_angle);

func get_mouse_relative_input() -> Vector2:
	return _mouse_relative;
func get_player_camera_analogue_input() -> Vector2:
	return Vector2(
		Input.get_axis("player_camera_left", "player_camera_right"),
		Input.get_axis("player_camera_up", "player_camera_down")
	);
func get_player_camera_input() -> Vector2:
	var camera_input := \
		(get_mouse_relative_input() * GameSettings.camera_mouse_sensitivity) + \
		(get_player_camera_analogue_input() * GameSettings.camera_analog_sensitivity);
	
	if (GameSettings.camera_invert_x): camera_input.x *= -1;
	if (GameSettings.camera_invert_y): camera_input.y *= -1;
	
	return camera_input;

################################################################################
# Vars

var _mouse_relative := Vector2.ZERO;

################################################################################
# Internals

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;

func _input(event: InputEvent) -> void:
	# Using controller check.
	if (event is InputEventKey or event is InputEventMouse):
		_set_property("is_using_controller", false);
	elif (event is InputEventJoypadButton):
		_set_property("is_using_controller", true);
	elif (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		_set_property("is_using_controller", true);
	
	# Get mouse movement.
	if (event is InputEventMouseMotion && active):
		_mouse_relative += Vector2(
			event.relative.x,
			event.relative.y
		);

func _process(_delta: float) -> void:
	if (_config_input_events_in_physics_process): return;
	_handle_input();
func _physics_process(_delta: float) -> void:
	if (!_config_input_events_in_physics_process): return;
	_handle_input();

func _handle_input() -> void:
	_reset_input.call_deferred();

func _reset_input() -> void:
	_mouse_relative = Vector2.ZERO;

func _update_mouse_visibility_state() -> void:
	if (is_mouse_locked()):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	elif (!is_mouse_visible()):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN;
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
