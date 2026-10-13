extends Control

@export var timeout : float = 45.0; # Total time to restart.
@onready var timeout_remaining : float = timeout;

@export var warning_threshold : float = 15.0;
@onready var warning_label : Label = $Margin/Label
@onready var warning_message : String = warning_label.text;

func _input(event : InputEvent) -> void:
	if (event is InputEventMouseMotion):
		# Mouse moved!
		timeout_remaining = timeout;

func _process(delta : float) -> void:
	# Update time.
	if (!GameState.active || Input.is_anything_pressed()):
		# Interaction!! Yippeeee!
		timeout_remaining = timeout;
	else:
		# No intentional interaction :(
		timeout_remaining -= delta;
	
	# Reset game.
	if (timeout_remaining <= 0 || Input.is_action_just_pressed("game_restart")):
		GameState.game_restart();
	# Update visuals.
	elif (timeout_remaining <= warning_threshold):
		visible = true;
		warning_label.text = warning_message % String.num(round(timeout_remaining), 0);
	else:
		visible = false;
