extends GutTest
## Test für Era1Monoch: Palette, Transition-Child, HUD-Refresh.

func test_palette_has_4_gb_colors() -> void:
	var r := Era1Monoch.new()
	assert_eq(r.get_palette().size(), 4)
	r.free()

func test_mount_adds_transition_child() -> void:
	var parent := Node.new()
	add_child(parent)
	var r := Era1Monoch.new()
	r.mount(parent)
	assert_not_null(r.get_node_or_null("EraTransition") as EraTransition)
	r.free()
	parent.free()
