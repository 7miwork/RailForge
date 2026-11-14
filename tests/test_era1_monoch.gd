extends GutTest
## Tests für Era1Monoch: Palette, Backdrop, Mount.

func test_palette_has_4_gb_colors() -> void:
	var r := Era1Monoch.new()
	assert_eq(r.get_palette().size(), 4)
	r.free()

func test_backdrop_is_gb_light() -> void:
	var r := Era1Monoch.new()
	assert_eq(r.get_backdrop_color(), Era1Monoch.GB_LIGHT)
	r.free()

func test_mount_adds_self_to_parent() -> void:
	var parent := Node.new()
	add_child(parent)
	var r := Era1Monoch.new()
	r.mount(parent)
	assert_true(parent.get_child(0) == r)
	# Kein EraTransition-Child mehr: der Manager besitzt die Transition.
	assert_eq(r.get_child_count(), 0)
	r.free()
	parent.free()
