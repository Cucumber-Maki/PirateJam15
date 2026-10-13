extends Control

@export var splash_images : Array[Texture];
@export var splash_time : float = 2.5;
var splash_time_remaining : float = 0.0;
var splash_index : int = -1;

@onready var splash_logo : TextureRect = $Background/Logo
@onready var splash_background : ColorRect = $Background


func _ready() -> void:
	splash_background.color = ProjectSettings.get_setting("application/boot_splash/bg_color");

func _input(event : InputEvent) -> void:
	if (event.is_pressed() && !event.is_echo()):
		cycle_to_next_splashscreen();

func _process(delta: float) -> void:
	if (splash_time_remaining > 0.0):
		splash_time_remaining -= delta;
	else:
		cycle_to_next_splashscreen();
		
	if (splash_index < splash_images.size()):
		splash_logo.texture = splash_images[splash_index];
		return;

	GameState.game_exit_to_menu();

func cycle_to_next_splashscreen() -> void:
	splash_index += 1;
	splash_time_remaining = splash_time;
