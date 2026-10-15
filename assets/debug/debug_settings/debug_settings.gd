extends GameSaveableBase;

################################################################################

# NOTE: This script pertains to features useful to debugging the game.

################################################################################

var render_colliders : bool = false;
var render_wireframe : bool = false;

################################################################################

func get_file_location() -> String:
	return "debug.txt"
	
func _ready() -> void:
	super();
	bind_on_property_change("render_colliders", _update_debug_collision_hint);

	RenderingServer.set_debug_generate_wireframes(true); # NOTE: Potential performance optimization?
	bind_on_property_change("render_wireframe", _update_wireframe_view);
	
func _update_debug_collision_hint(hint : bool) -> void:
	# Update visibility hint.
	if (get_tree().debug_collisions_hint == hint): return;
	get_tree().debug_collisions_hint = hint;
	
	# Tree recurse to update from hint.
	var queueStack : Array[Node] = [ get_tree().get_root() ];
	
	# Traverse tree to call update methods where available.
	while (!queueStack.is_empty()):
		# Get node.
		var node : Node = queueStack.pop_back()
		if (!is_instance_valid(node)): continue;
		
		# Update node.
		if (node is TileMapLayer || 
			node is CollisionObject2D || 
			node is CollisionShape3D):
			# Force redraw by re-adding to tree.
			var parent: Node = node.get_parent()
			if (parent != null):
				parent.remove_child(node);
				parent.add_child(node);
		
		# Recurse children.
		var children_count : int = node.get_child_count()
		for child_index in range(0, children_count):
			queueStack.push_back(node.get_child(child_index))

func _update_wireframe_view(wireframeVisible : bool) -> void:
	if (wireframeVisible):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	else:
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
	
################################################################################
