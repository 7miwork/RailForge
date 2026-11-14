extends GutTest
## Tests für EraTransition (Stub in Phase 1): Signal wird emittiert,
## kein State-Change, kein Crash.

func test_play_to_era_emits_signal() -> void:
	var node := EraTransition.new()
	add_child(node)
	var received: Array[int] = []
	node.transition_finished.connect(func(id: int) -> void: received.append(id))
	node.play_to_era(2)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(received, [2])
	node.free()

func test_play_to_era_does_not_touch_game_state() -> void:
	var node := EraTransition.new()
	add_child(node)
	var state := GameState.new()
	state.era = 1
	var before := state.to_dict()
	node.play_to_era(3)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(state.to_dict(), before)
	assert_eq(state.era, 1)
	node.free()
