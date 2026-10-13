extends OptionMenuBase;

func _ready() -> void:
	super();
	on_exit.connect(func() -> void: GameSettings.save_to_file());

func populate() -> void:
	add_label("Settings");

	start_tab("Game");
	add_label("Camera");
	add_slider("Mouse Sensitivity", InteractionInfo.from_game_saveable(GameSettings, "camera_mouse_sensitivity"), { "max_value": 10.0, "step": 0.25 });
	add_slider("Analog Sensitivity", InteractionInfo.from_game_saveable(GameSettings, "camera_analog_sensitivity"), { "max_value": 10.0, "step": 0.25 });
	add_checkbox("Invert Y", InteractionInfo.from_game_saveable(GameSettings, "camera_invert_y"));
	add_checkbox("Invert X", InteractionInfo.from_game_saveable(GameSettings, "camera_invert_x"));
	
	start_tab("Audio");
	add_label("Volume");
	
	for index in len(GameSettings.volume_settings):
		add_slider(
			AudioServer.get_bus_name(index) + " Volume", 
			InteractionInfo.from_game_saveable_array(GameSettings, "volume_settings", index)
		);
	
	end_tab();
	add_button("Save & Exit", InteractionInfo.navigate_exit(self));
