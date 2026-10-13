extends Control
class_name MenuStack;

################################################################################

signal menu_entered(menuName : String);
signal menu_exited(menuName : String);
signal menu_started;
signal menu_ended;

@export var default_menu : String = "";
@export var keep_open : bool = false;
var active_menu : MenuBase = null;
var stack : Array[String];

################################################################################

func _ready() -> void:
	for menu_node : Control in get_children():
		if (menu_node == null || !(menu_node is MenuBase)): continue;
		var menu := menu_node as MenuBase;
		menu.visible = false;
		menu.navigate_enter_menu.connect(menu_enter);
		menu.navigate_exit_menu.connect(menu_exit);
	menu_enter(default_menu);
	
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("menu_back") && active_menu != null):
		menu_exit();

################################################################################

func menu_enter(menuName: String) -> void:
	if (menuName == ""): 
		return;

	var nextMenu : MenuBase = find_child(menuName, false, false);
	if (nextMenu == null): 
		return;
		
	if (active_menu != null):
		stack.push_back(active_menu.name);
		_exit_menu();
	else:
		menu_started.emit();
	
	_enter_menu(nextMenu);

func menu_exit() -> void:
	if (stack.is_empty() && (keep_open || active_menu == null)):
		return;
	
	if (!(keep_open && stack.size() <= 0) && active_menu != null):
		_exit_menu();
	
	if (stack.is_empty()):
		menu_ended.emit();
		return;
	var nextMenuName : String = stack.pop_back();
	if (nextMenuName.is_empty()):
		return menu_exit();
	var nextMenu : MenuBase = find_child(nextMenuName, false, false);
	if (nextMenu == null): 
		return menu_exit();

	_enter_menu(nextMenu);

################################################################################

func _enter_menu(menu : MenuBase) -> void:
	active_menu = menu;
	active_menu.visible = true;
	if (active_menu.navigation_first != null):
		active_menu.navigation_first.grab_focus(!GameInput.is_using_controller)
	active_menu.on_enter.emit();
	menu_entered.emit(active_menu.name);

func _exit_menu() -> void:
	active_menu.on_exit.emit();
	menu_exited.emit(active_menu.name);
	active_menu.visible = false;
	active_menu = null;
