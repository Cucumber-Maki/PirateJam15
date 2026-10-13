extends Node;
class_name GameSaveableBase;

################################################################################

# NOTE: This script is the basis for saving and loading data between game 
# 		instances. All properties in this script are automatically included into
#		the saved data.

################################################################################

func get_file_location() -> String:
	# NOTE: This function is intended to be inherited and overwritten.
	Console.error(self.name, " file location not specified.");
	return "";

func get_folder_location() -> String:
	return "user://";
	
################################################################################
	
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	load_from_file();
	
################################################################################

func set_property(propertyName : StringName, value : Variant) -> void:
	# Safety first.
	if (!(propertyName in self)): return;
	
	# Compare values.
	if (get(propertyName) == value): return;
	
	# Debug print.
	Console.log("Set ", self.name, ".", propertyName, " to ", value, ".");
	
	# Update value.
	set(propertyName, value);
	
	# Emit signal.
	var signalName := "on_property_" + propertyName + "_change";
	if (has_user_signal(signalName)):
		emit_signal(signalName, value)

func bind_on_property_change(propertyName : StringName, callback : Callable) -> void:
	var propertyValue : Variant = get(propertyName);
	assert(propertyValue != null);
	assert(callback.get_argument_count() == 1);
	
	var signalName := "on_property_" + propertyName + "_change";
	if (!has_user_signal(signalName)):
		add_user_signal(signalName, [{ "name": "value", "type": typeof(propertyValue) }]);
	
	callback.call(propertyValue);
	connect(signalName, callback);

################################################################################

func save_to_file() -> void:
	# Safety first.
	var fileLocation : String = get_file_location();
	if (fileLocation == null || fileLocation == ""): return; 
	fileLocation = get_folder_location().path_join(fileLocation);
	
	# Information to store.
	var information : Dictionary = {};
	var rawProperties : Array = self.get_script().get_script_property_list();
	var defaultProperties : GameSaveableBase = self.get_script().new();
	for i : int in rawProperties.size():
		if (rawProperties[i].type == TYPE_NIL): continue;
		
		var property_name : String = rawProperties[i].name;
		var value : Variant = get(property_name);
		
		if (defaultProperties.get(property_name) != value):
			information[property_name] = value;
		
	# Ignore if no information is to be saved.
	if (information.size() <= 0): 
		# Remove previous save file if it exists.
		if (FileAccess.file_exists(fileLocation)):
			DirAccess.remove_absolute(fileLocation);
			Console.log("Removed ", self.name, " file due to all values matching defaults.");
		return;
	
	# Make sure folder exists.
	if (!DirAccess.dir_exists_absolute(get_folder_location())):
		DirAccess.make_dir_recursive_absolute(get_folder_location());
	
	# Get information string.
	var informationString : String = JSON.stringify(information);
	
	# Check if information changed.
	var loadFile : FileAccess = FileAccess.open(fileLocation, FileAccess.READ);
	if (loadFile != null):
		var fileContents : String = loadFile.get_as_text().replace("\n", "");
		
		# No need to save if the same.
		if (fileContents == informationString):
			return;
	
	# Open file.
	var saveFile : FileAccess = FileAccess.open(fileLocation, FileAccess.WRITE);
	if (saveFile == null):
		Console.error(self.name, " failed to open save file '", fileLocation, "'")
		return;
	
	# Store information.
	saveFile.store_string(informationString);
	saveFile.close();

	# Debug log.	
	Console.success(self.name, " successfully saved to file '", fileLocation, "'.");

func load_from_file() -> void:
	# Safety first.
	var fileLocation : String = get_file_location();
	if (fileLocation == null || fileLocation == ""): return; 
	fileLocation = get_folder_location().path_join(fileLocation);
	
	# Open file.
	if (!FileAccess.file_exists(fileLocation)): return;
	var loadFile : FileAccess = FileAccess.open(fileLocation, FileAccess.READ);
	
	# Load information.
	var json : JSON = JSON.new();
	var parsedData : Error = json.parse(loadFile.get_as_text().replace("\n", ""));
	if (parsedData != OK):
		Console.error(self.name, " failed to parse file '", fileLocation, "'.");
		return;
	
	# Set information.
	var information : Variant = json.get_data();
	for k : String in information.keys():
		if (k in self):
			# Get value.
			var currentValue : Variant = self.get(k);
			var value : Variant = information[k];
			
			if (currentValue != value && typeof(currentValue) == typeof(value)):
				# Output.
				Console.log(self.name, " loaded value ", k, " from file as ", value, ".");
				
				match (typeof(currentValue)):
					TYPE_ARRAY:
						if (len(currentValue) > len(value)):
							for i in len(value):
								currentValue[i] = value[i];
						else:
							var arr := currentValue as Array;
							arr.clear();
							arr.assign(value);
					_:
						# Set value.
						self.set(k, value);

	# Close file.
	loadFile.close();
	
	# Debug log.
	Console.success(self.name, " successfully loaded from file '", fileLocation, "'.");
	
################################################################################
