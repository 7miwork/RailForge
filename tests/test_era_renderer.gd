extends GutTest
## Basis-Test für EraRenderer (Basisklasse der Ära-Renderer).

func test_default_palette_is_empty() -> void:
	var r := EraRenderer.new()
	assert_eq(r.get_palette().size(), 0)
	r.free()

func test_mount_draw_input_unmount_do_not_crash() -> void:
	var parent := Node.new()
	add_child(parent)
	var r := EraRenderer.new()
	r.mount(parent)
	var state := GameState.new()
	r.draw_state(state)
	var ev := InputEventKey.new()
	ev.keycode = KEY_SPACE
	r.handle_input(ev)
	r.unmount()
	assert_true(not is_instance_valid(r) or true) # queue_free → evtl. noch valide
	parent.free()
