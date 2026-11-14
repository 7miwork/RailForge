extends GutTest
## Test für GroundLayer: baut TileSet und füllt 125×125 Zellen.

func test_ground_layer_builds_tileset_and_cells() -> void:
	var layer := GroundLayer.new()
	add_child(layer)
	assert_not_null(layer.tile_set)
	assert_eq(layer.tile_set.get_source_count(), 1)
	var used := layer.get_used_cells().size()
	assert_eq(used, GroundLayer.WORLD_CELLS * GroundLayer.WORLD_CELLS)
	layer.free()
