class_name InputCell

################################################################################

var state : bool;
var outputPos : Array[Vector2i];

################################################################################

func _init(_outputPos : Vector2i, outputCells : Dictionary) -> void:
	state = false;
	outputPos = [];
	addOutput(_outputPos, outputCells);

func addOutput(_outputPos : Vector2i, outputCells : Dictionary) -> void:
	outputPos.push_back(_outputPos);
	
	if (outputCells.has(_outputPos)):
		outputCells[_outputPos].remainingInputs += 1;
	else:
		outputCells[_outputPos] = OutputCell.new();

func setState(_state : bool, outputCells : Dictionary) -> void:
	if (state == _state): return;
	
	state = _state;
	
	for pos : Vector2i in outputPos:
		if (state): outputCells[pos].remainingInputs -= 1;
		else: outputCells[pos].remainingInputs += 1;
