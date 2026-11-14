class_name GroundLayer
extends TileMapLayer
## Baut das TileSet im Code (Ground-Textur wird prozedural zur Laufzeit
## von Tiles/TilesNES erzeugt – keine .tres mit Binär-Referenz) und füllt
## 125×125 Zellen (2000×2000 px). set_era() tauscht die Textur beim
## Ära-Wechsel (Game Boy ↔ NES).

const WORLD_CELLS := 125 # 125 × 16px = 2000px

func _ready() -> void:
	_build_tileset(1)
	_fill_cells()

func set_era(era: int) -> void:
	_build_tileset(era)
	_fill_cells()

func _build_tileset(era: int) -> void:
	var tile_size := Vector2i(16, 16)
	tile_set = TileSet.new()
	tile_set.tile_size = tile_size

	var source := TileSetAtlasSource.new()
	source.texture = _ground_texture(era)
	source.texture_region_size = tile_size
	source.create_tile(Vector2i.ZERO)
	tile_set.add_source(source, 0)

func _ground_texture(era: int) -> Texture2D:
	if era >= 2:
		return TilesNES.make_ground()
	return Tiles.make_ground()

func _fill_cells() -> void:
	for y in WORLD_CELLS:
		for x in WORLD_CELLS:
			set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
