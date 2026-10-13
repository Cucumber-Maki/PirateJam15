extends MenuBase
class_name OptionMenuBase;

################################################################################

func populate() -> void:
	# This is to be overwritten.
	pass;
	
################################################################################

@onready var root_node : Control = $PanelContainer/Margin/Layout;

var content_tab_container : TabContainer = null;
var focused_tab_container : TabContainer = null;
@onready var content_parent : Control = root_node;
var content_list_container : Control = null;
var content_grid_container : GridContainer = null;

################################################################################
# Common functions

func _ready() -> void:
	populate();
	
func clear() -> void:
	for child : Node in root_node.get_children():
		child.queue_free();
	content_tab_container = null;
	focused_tab_container = null;
	content_parent = root_node;
	content_list_container = null;
	content_grid_container = null;
	navigation_first = null;
	
func refresh() -> void:
	clear();
	populate();
	if (visible && navigation_first != null):
		navigation_first.grab_focus(!GameInput.is_using_controller);
	
class InteractionInfo:
	var value_initial : Variant = null;
	var value_callback : Callable = Callable();
	
	func _init(initial : Variant, callback : Callable) -> void:
		value_initial = initial;
		value_callback = callback;

	static func from_game_saveable(saveable : GameSaveableBase, property : String) -> InteractionInfo:
		assert(saveable.get(property) != null);
		return InteractionInfo.new(
			saveable.get(property), 
			func (value : Variant) -> void:
				saveable.set_property(property, value);
		);

	static func from_game_saveable_array(saveable : GameSaveableBase, property : String, index : int) -> InteractionInfo:
		assert(saveable.get(property) as Array != null);
		return InteractionInfo.new(
			saveable.get(property)[index],
			func(value : Variant) -> void:
				var temp : Variant = saveable.get(property).duplicate();
				temp[index] = value;
				saveable.set_property(property, temp);
		);

	static func callback_only(callback : Callable, p_intial_value : Variant = null) -> InteractionInfo:
		return InteractionInfo.new(p_intial_value, callback);

	static func navigate_enter(menu : MenuBase, menuName : String) -> InteractionInfo:
		return callback_only(func() -> void: menu.navigate_enter_menu.emit(menuName));

	static func navigate_exit(menu : MenuBase) -> InteractionInfo:
		return callback_only(func() -> void: menu.navigate_exit_menu.emit());

################################################################################
# Options

func start_tab(text : String) -> TabContainer:
	return _add_tab_container(text);

func end_tab() -> void:
	content_tab_container = null;
	content_parent = root_node;
	content_list_container = null;
	content_grid_container = null;
	
func add_label(text : String, properties : Dictionary = {}) -> Label:
	var label := Label.new();
	label.text = text;
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	_add_to_list_container(label);
	_set_properties(label, properties);
	return label;
	
func add_image(imagePath : String, min_width : float = -1, properties : Dictionary = {}) -> TextureRect:
	var textureRect : TextureRect = TextureRect.new();
	textureRect.texture = load(imagePath);
	textureRect.custom_minimum_size.x = min_width if (min_width >= 0) else (textureRect.texture.get_image().get_width() as float);
	textureRect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL;
	textureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;
	textureRect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER;
	textureRect.size_flags_vertical = Control.SIZE_SHRINK_CENTER;
	_set_properties(textureRect, properties);
	_add_to_list_container(textureRect);
	return textureRect;
	
func add_button(text : String, interaction : InteractionInfo = null, properties : Dictionary = {}) -> Button:
	var button : Button = Button.new();
	button.text = text;
	_add_to_list_container(button);
	_set_properties(button, properties);
	_bind_interaction(button, interaction);
	return button;
	
func add_slider(label : String, interaction : InteractionInfo = null, properties : Dictionary = {}) -> Slider:
	var slider := HSlider.new();
	slider.custom_minimum_size.x = 100;
	slider.min_value = 0.0;
	slider.max_value = 1.0;
	slider.step = 0.025;
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER;
	_add_to_grid_container(label, slider);
	_set_properties(slider, properties);
	_bind_interaction(slider, interaction);
	return slider;
	
func add_checkbox(label : String, interaction : InteractionInfo = null, properties : Dictionary = {}) -> CheckBox:
	var checkbox : CheckBox = CheckBox.new();
	checkbox.alignment = HORIZONTAL_ALIGNMENT_CENTER;
	checkbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER;
	_add_to_grid_container(label, checkbox);
	_set_properties(checkbox, properties);
	_bind_interaction(checkbox, interaction);
	return checkbox;

func add_grid_row(p_left : Control, p_right : Control) -> void:
	if (content_grid_container == null):
		var gridContainer : GridContainer = preload("res://assets/menus/_implementation/content/grid.tscn").instantiate();
		_add_to_list_container(gridContainer);
		content_grid_container = gridContainer;
	
	# Left.
	if (p_left.get_parent_control() != null):
		p_left.reparent(content_grid_container);
	else:
		content_grid_container.add_child(p_left);
	_bind_navigation_first(p_left);
	
	# Right.
	if (p_right.get_parent_control() != null):
		p_right.reparent(content_grid_container);
	else:
		content_grid_container.add_child(p_right);
	_bind_navigation_first(p_right);

################################################################################
# Internal

func _process(_delta: float) -> void:
	if (!visible || focused_tab_container == null): return;
		
	if (Input.is_action_just_released("menu_tab_right")):
		focused_tab_container.get_tab_bar().select_next_available();
		focused_tab_container.get_tab_bar().grab_focus();
	elif (Input.is_action_just_released("menu_tab_left")):
		focused_tab_container.get_tab_bar().select_previous_available();
		focused_tab_container.get_tab_bar().grab_focus();

func _add_tab_container(text : String) -> TabContainer:
	if (content_tab_container == null):
		content_tab_container = preload("res://assets/menus/_implementation/content/tab_container.tscn").instantiate();
		root_node.add_child(content_tab_container);
	
	var tab : Control = preload("res://assets/menus/_implementation/content/tab.tscn").instantiate();
	tab.name = text;
	content_tab_container.add_child(tab);
	content_parent = _get_last_child(tab);
	
	content_list_container = null;
	content_grid_container = null;
	
	if (focused_tab_container == null):
		focused_tab_container = content_tab_container;
	
	_bind_navigation_first(content_tab_container.get_tab_bar());
	return content_tab_container;

func _add_to_list_container(element : Control) -> void:
	content_grid_container = null;
	if (content_list_container == null):
		var list : Control = preload("res://assets/menus/_implementation/content/content.tscn").instantiate();
		content_parent.add_child(list);
		content_list_container = _get_last_child(list);
	
	content_list_container.add_child(element);
	_bind_navigation_first(element);

func _add_to_grid_container(text : String, element : Control) -> void:
	var label := Label.new();
	label.text = text;
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	add_grid_row(label, element);

func _get_last_child(element : Control) -> Control:
	while (element.get_child_count() > 0):
		element = element.get_child(0);
	return element;

func _bind_navigation_first(element : Control) -> void:
	if (navigation_first != null): return;
	if (element.get_focus_mode_with_override() == Control.FocusMode.FOCUS_NONE): return;
	navigation_first = element;

func _bind_interaction(element : Control, interaction : InteractionInfo) -> void:
	if (interaction == null): 
		return;
	
	match (element.get_class()):
		"Button":
			var button : Button = element;
			if (interaction.value_callback.is_valid()):
				button.pressed.connect(interaction.value_callback);
		"HSlider":
			var slider : HSlider = element;
			if (interaction.value_initial != null):
				slider.value = interaction.value_initial;
			if (interaction.value_callback.is_valid()):
				slider.value_changed.connect(interaction.value_callback);
		"CheckBox":
			var checkBox : CheckBox = element;
			if (interaction.value_initial != null):
				checkBox.button_pressed = interaction.value_initial;
			if (interaction.value_callback.is_valid()):
				checkBox.pressed.connect(func() -> void: interaction.value_callback.call(checkBox.button_pressed));
		_:
			push_error("_bind_interaction has no support for ", element.get_class());

func _set_properties(element : Control, properties : Dictionary) -> void:
	for key : String in properties.keys():
		if (key is not String): continue;
		element.set(key, properties[key]);
