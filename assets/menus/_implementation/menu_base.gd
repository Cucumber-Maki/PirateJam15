extends Control
class_name MenuBase;

signal on_enter;
signal on_exit;

signal navigate_enter_menu(menuName : String);
signal navigate_exit_menu();

var navigation_first : Control = null;
