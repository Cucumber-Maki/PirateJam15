extends Node2D

@export var walls : TileMap;

func _ready() -> void:
	var tileSize := walls.tile_set.tile_size;
	var offset := Vector2(walls.get_used_rect().position * tileSize);
	var size := Vector2(walls.get_used_rect().size * tileSize);
	
	$Camera.global_position = walls.global_position + (size / 2.0) + offset;
	var zoomRaw := Vector2(get_viewport_rect().size) / (size - (tileSize * 2.0));
	var zoom : float = min(zoomRaw.x, zoomRaw.y);
	$Camera.zoom = Vector2(zoom, zoom); 

func gotoLevelSelect(completed : bool = false) -> void:
	var children : Array[Node] = get_tree().root.get_children();
	print(children.back().name);
	children.back().queue_free();
	
	if (completed):
		#get_tree().root.get_child(0).completeLevel(self.name);
		get_tree().current_scene.completeLevel(self.name);
