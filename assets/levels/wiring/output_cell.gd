class_name OutputCell
################################################################################

var remainingInputs : int;

################################################################################

func _init() -> void:
	remainingInputs = 1;

func getState() -> bool:
	return remainingInputs <= 0;
