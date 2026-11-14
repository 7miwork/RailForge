extends GutTest
## Tests für EraManager: Initial-Mount, Ära-Tausch mit Transition,
## Viewport-Umschaltung, Inventar-Erhalt, Rückwechsel.

var world_view: SubViewportContainer
var manager: EraManager
var state: GameState

func before_each() -> void:
	var packed := load("res://scenes/world_view.tscn") as PackedScene
	world_view = packed.instantiate()
	add_child(world_view)
	manager = EraManager.new()
	add_child(manager)
	manager.setup(world_view)
	state = GameState.new()
	state.inventory.add_item("wood", 7, 99)

func after_each() -> void:
	if is_instance_valid(world_view):
		world_view.free()
	if is_instance_valid(manager):
		manager.free()

func test_mount_initial_era1() -> void:
	manager.mount_initial(state)
	assert_true(manager.current_renderer is Era1Monoch)
	assert_eq(state.era, 1)
	var viewport := world_view.get_node("Viewport") as SubViewport
	assert_eq(viewport.size, Vector2i(160, 144))

func test_change_to_era2_swaps_renderer_and_keeps_state() -> void:
	manager.mount_initial(state)
	manager.change_era(2, state)
	# Transition läuft ~1,5 s (6×0,12 Flackern + 0,25 Cover + 0,65 Reveal).
	await get_tree().create_timer(2.2).timeout
	assert_true(manager.current_renderer is Era2Nes)
	assert_eq(state.era, 2)
	# Inventar bleibt erhalten.
	assert_eq(state.inventory.count_item("wood"), 7)
	# Viewport auf NES-Auflösung umgestellt.
	var viewport := world_view.get_node("Viewport") as SubViewport
	assert_eq(viewport.size, Vector2i(256, 240))
	# Meilenstein wurde markiert.
	assert_true(EraUnlocks.unlocked_eras(state).has(2))

func test_change_back_to_era1() -> void:
	manager.mount_initial(state)
	manager.change_era(2, state)
	await get_tree().create_timer(2.2).timeout
	manager.change_era(1, state)
	await get_tree().create_timer(2.2).timeout
	assert_true(manager.current_renderer is Era1Monoch)
	assert_eq(state.era, 1)
	var viewport := world_view.get_node("Viewport") as SubViewport
	assert_eq(viewport.size, Vector2i(160, 144))

func test_change_to_era_without_renderer_is_noop() -> void:
	manager.mount_initial(state)
	manager.change_era(5, state)
	await get_tree().process_frame
	assert_true(manager.current_renderer is Era1Monoch)
	assert_eq(state.era, 1)

func test_save_load_era2_roundtrip() -> void:
	state.era = 2
	state.features["unlocked_eras"] = [2]
	var loaded := GameState.from_dict(state.to_dict())
	assert_eq(loaded.era, 2)
	assert_true(EraUnlocks.unlocked_eras(loaded).has(2))
