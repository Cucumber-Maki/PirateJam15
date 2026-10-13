extends OptionMenuBase;

func _ready() -> void:
	super();
	GameState.bind_on_property_change("debug_is_enabled", func(_v : bool) -> void: refresh());

func populate() -> void:
	add_label("Game Paused");
	add_button("Resume", InteractionInfo.navigate_exit(self));
	add_button("Settings", InteractionInfo.navigate_enter(self, "Settings Menu"));
	if (GameState.debug_is_enabled):
		add_button("Debug", InteractionInfo.navigate_enter(self, "Debug Menu"));

	add_button("Exit to Main Menu", InteractionInfo.callback_only(func() -> void: GameState.game_exit_to_menu()));
