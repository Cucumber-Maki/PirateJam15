extends Node2D
class_name Lighting;

################################################################################

const TILE_SCALE : float = 36.0;
const LIGHTING_WIDTH = 8;

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT,
};
func flip_direction(p_direction : Direction) -> Direction:
	return ((p_direction + 2) % 4) as Direction;
	
enum LightingValue {
	RED = 1 << 0,
	GREEN = 1 << 1,
	BLUE = 1 << 2,
	SHADOW = 1 << 3,
};
const LIGHTING_VALUE_COLOR_MASK : int = LightingValue.RED | LightingValue.GREEN | LightingValue.BLUE;
const LIGHTING_VALUE_SHADOW_MASK : int = LightingValue.SHADOW;

var emitters : Array[Emitter] = [];

var object_manager : ObjectProcess = get_parent();

################################################################################

func check_if_solid(p_pos : Vector2i) -> bool:
	if (get_parent().checkIfWall(p_pos)): return true;
	var entity_type : ObjectProcess.EntityTileType = get_parent().getEntityTileType(p_pos);
	return get_parent().isEntityTypeSolid(entity_type);
func check_if_shadowable(p_pos : Vector2i) -> bool:
	if (get_parent().checkIfWall(p_pos)): return false;
	var entity_type : ObjectProcess.EntityTileType = get_parent().getEntityTileType(p_pos);
	return get_parent().isEntityTypeShadowable(entity_type);
		
func get_lighting_color(p_lighting : int) -> Color:
	var color : Color = Color.BLACK;
	if (p_lighting & LightingValue.RED): color.r = 1.0;
	if (p_lighting & LightingValue.GREEN): color.g = 1.0;
	if (p_lighting & LightingValue.BLUE): color.b = 1.0;
	if (p_lighting & LightingValue.SHADOW):
		color.r *= 0.5;
		color.g *= 0.5;
		color.b *= 0.5;
	return color;

var lighting_data : Dictionary = {};
func update_lighting() -> void: 
	lighting_data.clear();
	
	# Handle Lighting.
	var end_points : Dictionary = {};
	for emitter in emitters:
		if (!emitter.enabled): continue;
		var pos : Vector2i = emitter.position;
		
		var color : int = emitter.color;
		var max_length : int = 100;
		while (max_length > 0):
			max_length -= 1;
			
			match (emitter.direction):
				Direction.UP: pos.y -= 1;
				Direction.RIGHT: pos.x += 1;
				Direction.DOWN: pos.y += 1;
				Direction.LEFT: pos.x -= 1;
			
			if (check_if_solid(pos)):
				if (check_if_shadowable(pos)):
					var arr : Array[Dictionary] = [];
					if (end_points.has(pos)): arr = end_points[pos];
					else: end_points[pos] = arr;
					
					arr.push_back({
						"direction": emitter.direction,
						"color": color,
					});
				break;
			
			var lighting_data_pos : LightData = LightData.new() if !lighting_data.has(pos) else lighting_data[pos];
			
		
			lighting_data_pos.data[emitter.direction].color |= color;
			lighting_data_pos.data[flip_direction(emitter.direction)].color |= color;
			lighting_data_pos.data[flip_direction(emitter.direction)].is_input = true;
			
			if (lighting_data.has(pos)):
				color = propagate_lighting(pos, flip_direction(emitter.direction));
				lighting_data_pos.data[emitter.direction].color |= color;
				lighting_data_pos.calculate_total_color();
			else:
				lighting_data_pos.calculate_total_color();
				lighting_data[pos] = lighting_data_pos;
	
	# Handle shadows.
	for end_pos : Vector2i in end_points:
		for end_info : Dictionary in end_points[end_pos]:
			var direction : Direction = end_info["direction"];
			var color : int = end_info["color"] | LightingValue.SHADOW;
			
			var pos : Vector2i = end_pos;
			var origin_pos : Vector2i = end_pos;
			match (direction):
				Direction.UP: origin_pos.y += 1;
				Direction.RIGHT: origin_pos.x -= 1;
				Direction.DOWN: origin_pos.y -= 1;
				Direction.LEFT: origin_pos.x += 1;
			
			if (lighting_data.has(origin_pos)):
				color = lighting_data[origin_pos].color | LightingValue.SHADOW;
			
			var max_length : int = 100;
			while (max_length > 0):
				max_length -= 1;
				
				match (direction):
					Direction.UP: pos.y -= 1;
					Direction.RIGHT: pos.x += 1;
					Direction.DOWN: pos.y += 1;
					Direction.LEFT: pos.x -= 1;
				
				if (check_if_solid(pos)):
					break;
	
				if (lighting_data.has(pos)):
					var lighting_data_pos : LightData = lighting_data[pos];
					if (lighting_data_pos.data[flip_direction(direction)].color): 
						if (lighting_data_pos.data[flip_direction(direction)].is_input || \
							!(lighting_data_pos.data[flip_direction(direction)].color & LightingValue.SHADOW)):
							break;
					
					lighting_data_pos.data[flip_direction(direction)].color |= color;
					lighting_data_pos.data[flip_direction(direction)].is_input = true;
					
					# Don't propagate into lighting.
					if (!(lighting_data_pos.color & LightingValue.SHADOW)): break;
					
					# Propagate shadows.
					lighting_data_pos.data[direction].color |= color;
					color = propagate_lighting(pos, flip_direction(direction));
				else:
					var lighting_data_pos : LightData = LightData.new();
					lighting_data_pos.data[direction].color |= color;
					lighting_data_pos.data[flip_direction(direction)].color |= color;
					lighting_data_pos.data[flip_direction(direction)].is_input = true;
					lighting_data_pos.calculate_total_color();
					lighting_data[pos] = lighting_data_pos;
	
	queue_redraw();

func propagate_lighting(p_pos : Vector2i, _fromDirection : Direction) -> int:
	# Get lighting point data.
	if (!lighting_data.has(p_pos)): return 0;
	var lighting_data_pos : LightData = lighting_data[p_pos];
	
	# Make sure color is calculated.
	var previous_color : int = lighting_data_pos.color;
	lighting_data_pos.calculate_total_color();
	var color : int = lighting_data_pos.color;
	
	if (color == previous_color): return color;
	
	# Find propagation targets.
	var propagation_directions : Array[Direction] = [ ];
	for light_info : LightingInformation in lighting_data_pos.data:
		if (light_info.is_input):
			propagation_directions.push_back(flip_direction(light_info.direction));
	
	# Propagate.
	for direction : Direction in propagation_directions:
		lighting_data_pos.data[direction].color = color;
		
		var target_pos : Vector2i = p_pos;
		match (direction):
			Direction.UP: target_pos.y -= 1;
			Direction.RIGHT: target_pos.x += 1;
			Direction.DOWN: target_pos.y += 1;
			Direction.LEFT: target_pos.x -= 1;
		
		if (lighting_data.has(target_pos)):
			var lighting_data_target_pos : LightData = lighting_data[target_pos];
			lighting_data_target_pos.data[flip_direction(direction)].color = color;
			propagate_lighting(target_pos, flip_direction(direction));
		
	return color;

func _ready() -> void:
	update_lighting();

################################################################################
# Emitter stuff

func add_emitter(p_emitter : Emitter) -> bool:
	for emitter : Emitter in emitters:
		if (emitter.position == p_emitter.position):
			return false;
	
	emitters.push_back(p_emitter);
	return true;
	
func remove_emitter(p_emitter_pos : Vector2i) -> void:
	for i : int in range(len(emitters)):
		if (emitters[i].position == p_emitter_pos):
			emitters.remove_at(i);
			break;
	
func move_emitter(p_emitter_pos : Vector2i, p_new_pos : Vector2i) -> void:
	var temp_emitter : Emitter = null;
	for emitter : Emitter in emitters:
		if (emitter.position == p_emitter_pos):
			temp_emitter = emitter;
			break;
	
	if (add_emitter(Emitter.new(p_new_pos, temp_emitter.color, temp_emitter.direction))):
		remove_emitter(p_emitter_pos);
	
func enable_emitter(p_emitter_pos : Vector2i) -> void:
	for emitter : Emitter in emitters:
		if (emitter.position == p_emitter_pos):
			emitter.enabled = true;
			break;
			
func disable_emitter(p_emitter_pos : Vector2i) -> void:
	for emitter : Emitter in emitters:
		if (emitter.position == p_emitter_pos):
			emitter.enabled = false;
			break;
	
func clear_emitters() -> void:
	emitters.clear();

################################################################################

func _draw() -> void:
	for pos : Vector2i in lighting_data:
		var mid_point : Vector2 = Vector2(pos) + Vector2(0.5, 0.5);
		for lighting_info : LightingInformation in lighting_data[pos].data:
			if (!lighting_info.color): continue;
			
			var side_pos : Vector2 = Vector2(pos);
			match (lighting_info.direction):
				Direction.UP: 
					side_pos.x += 0.5;
				Direction.RIGHT: 
					side_pos.x += 1.0; 
					side_pos.y += 0.5;
				Direction.DOWN: 
					side_pos.x += 0.5; 
					side_pos.y += 1.0;
				Direction.LEFT: 
					side_pos.y += 0.5;
			
			draw_line(
				side_pos * TILE_SCALE, 
				mid_point * TILE_SCALE, 
				get_lighting_color(lighting_info.color), LIGHTING_WIDTH, false
			);
			
		@warning_ignore("integer_division")
		draw_line(
			(mid_point * TILE_SCALE) + Vector2(0, LIGHTING_WIDTH / 2), 
			(mid_point * TILE_SCALE) + Vector2(0, -LIGHTING_WIDTH / 2), 
			get_lighting_color(lighting_data[pos].color), LIGHTING_WIDTH, false
		);
