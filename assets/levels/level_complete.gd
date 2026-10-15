extends CanvasLayer

func _ready() -> void:
	var levelName : String = $"../".name;
	var artefactPath : String = ArtefactConfig.get_level_artefact_path(levelName);
	if (!ResourceLoader.exists(artefactPath)): return;
	$Margin/HBox/Panel/VBox/Artefact.texture = ResourceLoader.load(artefactPath);
	
	var artefactName: String = ArtefactConfig.get_level_artefact_name(artefactPath);
	if (artefactName.contains("\n")):
		$Margin/HBox/Panel/VBox/VBox/Background/ArtefactName.add_theme_font_size_override("font_size", 35);
		artefactName = artefactName.replace("\n", " ");
	$Margin/HBox/Panel/VBox/VBox/Background/ArtefactName.text = "- " + artefactName + " -";
	
func levelComplete() -> void:
	visible = true;

func goBack() -> void:
	$"../".gotoLevelSelect(true);
