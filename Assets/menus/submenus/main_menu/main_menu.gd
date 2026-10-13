extends OptionMenuBase

func populate() -> void:
	#addImage("res://assets/menus/mainMenu/title.png")
	add_button("Play", InteractionInfo.callback_only(func() -> void: GameState.scene_change("res://scenes/game/game.tscn")));
	add_button("Settings", InteractionInfo.navigate_enter(self, "Settings Menu"));

	if (OS.get_name() != "Web"):
		add_button("Exit Game", InteractionInfo.callback_only(func() -> void: GameState.game_exit()));
