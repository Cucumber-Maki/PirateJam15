extends OptionMenuBase;

func _ready() -> void:
	super();
	on_exit.connect(func() -> void: DebugSettings.save_to_file());

func populate() -> void:
	add_label("Debug Settings");
	
	start_tab("Visual")
	add_checkbox("Render Colliders", InteractionInfo.from_game_saveable(DebugSettings, "render_colliders"));
	add_checkbox("Render Wireframes", InteractionInfo.from_game_saveable(DebugSettings, "render_wireframe"));
	end_tab()
	
	add_button("Save & Exit", InteractionInfo.navigate_exit(self));
