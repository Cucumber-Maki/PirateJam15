extends Node
class_name ArtefactConfig;

static func get_level_artefact_path(levelName : String) -> String:
	match (levelName):
		"1": return "res://assets/artefacts/0.png";
		"2": return "res://assets/artefacts/1.png";
		"3": return "res://assets/artefacts/2.png";
		"4": return "res://assets/artefacts/3.png";
		"5": return "res://assets/artefacts/4.png";
		"6": return "res://assets/artefacts/5.png";
		"7": return "res://assets/artefacts/6.png";
		"8": return "res://assets/artefacts/7.png";
		"9": return "res://assets/artefacts/8.png";
		"Fin": return "res://assets/artefacts/10.png";
	return "res://assets/artefacts/11.png";

static func get_level_artefact_name(path : String) -> String:
	match (path):
		"res://assets/artefacts/0.png": return "Jem";
		"res://assets/artefacts/1.png": return "Cool ass sword.";
		"res://assets/artefacts/2.png": return "CUTE LIL' PLUSH";
		"res://assets/artefacts/3.png": return "Stick of... Gold?";
		"res://assets/artefacts/4.png": return "Somebody has\nmy rabbit?!";
		"res://assets/artefacts/5.png": return "Jar of sand";
		"res://assets/artefacts/6.png": return "Divergentleman";
		"res://assets/artefacts/7.png": return "Someone Else's\nSelf Portrait";
		"res://assets/artefacts/8.png": return "Fool's Luck";
		"res://assets/artefacts/9.png": return "Glizz";
		"res://assets/artefacts/10.png": return "Anxiety flavoured\nPop Rocks";
		"res://assets/artefacts/11.png": return "A job well done.";
	return "???"
