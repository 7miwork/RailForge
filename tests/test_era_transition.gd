extends GutTest
## Tests für EraTransition: Signal erst nach Animation (~1,5 s),
## Input-Lock währenddessen, dann wieder frei. Kein State-Change.

func test_play_to_era_emits_signal_after_animation() -> void:
	var node := EraTransition.new()
	add_child(node)
	var received: Array[int] = []
	node.transition_finished.connect(func(id: int) -> void: received.append(id))
	node.play_to_era(2)
	# Direkt nach dem Aufruf noch kein Signal (Animation läuft).
	await get_tree().process_frame
	assert_eq(received, [])
	assert_true(EraTransition.input_locked)
	# Nach ~2 s muss das Signal da sein und der Lock aufgehoben.
	await get_tree().create_timer(2.2).timeout
	assert_eq(received, [2])
	assert_false(EraTransition.input_locked)
	node.free()

func test_play_to_era_does_not_touch_game_state() -> void:
	var node := EraTransition.new()
	add_child(node)
	var state := GameState.new()
	state.era = 1
	var before := state.to_dict()
	node.play_to_era(3)
	await get_tree().create_timer(2.2).timeout
	assert_eq(state.to_dict(), before)
	assert_eq(state.era, 1)
	node.free()

func test_double_play_is_ignored() -> void:
	var node := EraTransition.new()
	add_child(node)
	var received: Array[int] = []
	node.transition_finished.connect(func(id: int) -> void: received.append(id))
	node.play_to_era(2)
	node.play_to_era(1) # wird ignoriert (_playing)
	await get_tree().create_timer(2.2).timeout
	assert_eq(received, [2])
	node.free()
