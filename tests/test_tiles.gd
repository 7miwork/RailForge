extends GutTest
## Tests für Tiles: Größe, Game-Boy-Palette (ausschließlich 4 Farben),
## Determinismus.

const PALETTE: Array[Color] = [
	Color("#0f380f"), # GB_DARKEST
	Color("#306230"), # GB_DARK
	Color("#8bac0f"), # GB_LIGHT
	Color("#9bbc0f"), # GB_LIGHTEST
]

func _assert_only_gb_colors(img: Image, size: Vector2i) -> void:
	assert_eq(img.get_size(), size)
	for y in size.y:
		for x in size.x:
			var c := img.get_pixel(x, y)
			if c.a == 0.0:
				continue # transparente Pixel (z. B. Spieler-Hintergrund) erlaubt
			assert_true(PALETTE.has(c), "Pixel (%d,%d) nicht in GB-Palette: %s" % [x, y, c])

func test_ground_size_and_palette() -> void:
	_assert_only_gb_colors(Tiles.make_ground().get_image(), Vector2i(16, 16))

func test_wood_node_palette() -> void:
	_assert_only_gb_colors(Tiles.make_wood_node().get_image(), Vector2i(16, 16))

func test_stone_node_palette() -> void:
	_assert_only_gb_colors(Tiles.make_stone_node().get_image(), Vector2i(16, 16))

func test_iron_node_palette() -> void:
	_assert_only_gb_colors(Tiles.make_iron_node().get_image(), Vector2i(16, 16))

func test_player_size_and_palette() -> void:
	_assert_only_gb_colors(Tiles.make_player().get_image(), Vector2i(8, 8))

func test_ground_deterministic() -> void:
	var a := Tiles.make_ground().get_image().get_data()
	var b := Tiles.make_ground().get_image().get_data()
	assert_eq(a, b)

func test_player_has_transparency() -> void:
	# Ecke (0,0) ist Outline → deckend; aber es muss transparente Pixel geben.
	var img := Tiles.make_player().get_image()
	var transparent_found := false
	for y in 8:
		for x in 8:
			if img.get_pixel(x, y).a == 0.0:
				transparent_found = true
	assert_true(transparent_found, "Spieler-Textur hat keine transparenten Pixel")
