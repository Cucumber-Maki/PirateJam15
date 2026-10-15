extends Node
class_name GameSettableBase;

################################################################################

func _set_property(propertyName : StringName, value : Variant) -> void:
	# Safety first.
	if (!(propertyName in self)): return;
	
	# Compare values.
	if (get(propertyName) == value): return;
	
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
