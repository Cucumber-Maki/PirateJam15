extends Node

signal on_print(message : String, color : Color)

const _color_default : Color = Color("ffffff");
const _color_log : Color = Color("738aff");
const _color_warning : Color = Color("ffd994");
const _color_error : Color = Color("ff738a");
const _color_success : Color = Color("73ff8a");

func print(...args : Array[Variant]) -> void:
	printRaw(_color_default, args);
func log(...args : Array[Variant]) -> void:
	printRaw(_color_log, args);
func warning(...args : Array[Variant]) -> void:
	printRaw(_color_warning, args);
func error(...args : Array[Variant]) -> void:
	printRaw(_color_error, args);
func success(...args : Array[Variant]) -> void:
	printRaw(_color_success, args);
func printColor(color : Color, ...args : Array[Variant]) -> void:
	printRaw(color, args);

func printRaw(color : Color, args : Array[Variant]) -> void:
	# Convert args to string.
	var message : String = "%s".repeat(args.size()).strip_edges() % args;
	# Send signal.
	on_print.emit(message, color);
	# Print string.
	print_rich("[color="+color.to_html()+"]", message, "[/color]")
