extends GutTest
## Tests für TilesNES: Größe, Palette (ausschließlich NES-Farben), Determinismus.

const PALETTE: Array[Color] = TilesNES.NES_PALETTE

func _assert_only_nes_colors(img: Image, size: Vector2i) -> void:
	assert_eq(img.get_size(), size)
	for y in size.y:
		for x in size.x:
			var c := img.get_pixel(x, y)
			if c.a == 0.0:
				continue
			assert_true(PALETTE.has(c), "Pixel (%d,%d) nicht in NES-Palette: %s" % [x, y, c])

func test_ground_size_and_palette() -> void:
	_assert_only_nes_colors(TilesNES.make_ground().get_image(), Vector2i(16, 16))

func test_wood_node_palette() -> void:
	_assert_only_nes_colors(TilesNES.make_wood_node().get_image(), Vector2i(16, 16))

func test_stone_node_palette() -> void:
	_assert_only_nes_colors(TilesNES.make_stone_node().get_image(), Vector2i(16, 16))

func test_iron_node_palette() -> void:
	_assert_only_nes_colors(TilesNES.make_iron_node().get_image(), Vector2i(16, 16))

func test_player_size_and_palette() -> void:
	_assert_only_nes_colors(TilesNES.make_player().get_image(), Vector2i(16, 16))

func test_ground_deterministic() -> void:
	var a := TilesNES.make_ground().get_image().get_data()
	var b := TilesNES.make_ground().get_image().get_data()
	assert_eq(a, b)

func test_ground_differs_from_gb() -> void:
	# NES-Boden muss sich sichtbar von GB-Boden unterscheiden.
	var nes := TilesNES.make_ground().get_image().get_pixel(0, 0)
	var gb := Tiles.make_ground().get_image().get_pixel(0, 0)
	assert_ne(nes, gb)
