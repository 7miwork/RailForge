class_name GroundLayer
extends TileMapLayer
## ground_tileset.tres ist nicht möglich, da die Ground-Textur prozedural
## zur Laufzeit erzeugt wird (Tiles.make_ground()). Daher wird das TileSet
## hier im Code aufgebaut und die 125×125-Zellen (2000×2000 px) gefüllt.

const WORLD_CELLS := 125 # 125 × 16px = 2000px

func _ready() -> void:
	var tile_size := Vector2i(16, 16)
	tile_set = TileSet.new()
	tile_set.tile_size = tile_size

	var source := TileSetAtlasSource.new()
	source.texture = Tiles.make_ground()
	source.texture_region_size = tile_size
	source.create_tile(Vector2i.ZERO)
	tile_set.add_source(source, 0)

	for y in WORLD_CELLS:
		for x in WORLD_CELLS:
			set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
