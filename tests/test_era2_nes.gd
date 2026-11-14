extends GutTest
## Tests für Era2Nes: Palette (NES-Farben, Größe), Mount/Unmount.

func test_palette_size_and_unique() -> void:
	var r := Era2Nes.new()
	var palette := r.get_palette()
	assert_true(palette.size() >= 16 and palette.size() <= 24)
	# Alle Paletten-Farben sind deckend und eindeutig.
	var unique := {}
	for c: Color in palette:
		assert_eq(c.a, 1.0)
		unique[c.to_html()] = true
	assert_eq(unique.size(), palette.size())
	r.free()

func test_palette_matches_tiles_nes() -> void:
	var r := Era2Nes.new()
	assert_eq(r.get_palette(), TilesNES.NES_PALETTE)
	r.free()

func test_backdrop_color_is_sky() -> void:
	var r := Era2Nes.new()
	assert_eq(r.get_backdrop_color(), TilesNES.SKY)
	r.free()

func test_mount_unmount() -> void:
	var parent := Node.new()
	add_child(parent)
	var r := Era2Nes.new()
	r.mount(parent)
	assert_eq(parent.get_child_count(), 1)
	assert_true(parent.get_child(0) == r)
	r.unmount()
	await get_tree().process_frame
	assert_eq(parent.get_child_count(), 0)
	parent.free()
