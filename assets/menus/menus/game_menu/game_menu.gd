extends MenuStack

################################################################################

func _ready() -> void:
	GameInput.active = true;
	
	menu_started.connect(func() -> void:
		# Take user control.
		GameState.paused = true;
		GameInput.active = false;
	);
	menu_ended.connect(func() -> void:
		# Reset user control.
		GameState.paused = false;
		GameInput.active = true;
	);
	
	super();

################################################################################

func _process(_delta : float) -> void:
	if (Input.is_action_just_pressed("player_pause") && active_menu == null):
		# Enter pause menu.
		menu_enter("Pause Menu");
	else:
		super(_delta);

func _notification(what : int) -> void:
	if (what == NOTIFICATION_WM_WINDOW_FOCUS_OUT && active_menu == null):
		menu_enter("Pause Menu");
