extends GutTest
## Tests für Progress (Etappen-Fortschritt) und GameState (Save-Round-Trip).

var progress: Progress

func before_each() -> void:
	progress = Progress.new()

func test_current_stage_is_1_4() -> void:
	# data/progress.json hat 1.1–1.3 bereits als done markiert.
	assert_eq(progress.current_stage_id(), "1.4")

func test_current_stage_name() -> void:
	assert_eq(progress.current_stage_name(), "Speichern/Laden & Debug-Menü")

func test_current_stage_dict() -> void:
	var stage := progress.current_stage()
	assert_eq(str(stage.get("id")), "1.4")
	assert_false(bool(stage.get("done")))

func test_mark_done_advances_stage() -> void:
	progress.mark_done("1.4")
	assert_eq(progress.current_stage_id(), "1.5")
	assert_eq(progress.current_stage_name(), "Fortschrittsanzeige & GUT-Tests")

func test_game_state_roundtrip() -> void:
	var s := GameState.new()
	s.phase = 1
	s.stage = "1.4"
	s.stage_name = "Speichern/Laden & Debug-Menü"
	s.tick = 42
	s.era = 1
	s.inventory.add_item("wood", 10, 99)
	s.stats["wood_collected"] = 7

	var restored := GameState.from_dict(s.to_dict())
	assert_eq(restored.phase, 1)
	assert_eq(restored.stage, "1.4")
	assert_eq(restored.stage_name, "Speichern/Laden & Debug-Menü")
	assert_eq(restored.tick, 42)
	assert_eq(restored.era, 1)
	assert_eq(restored.inventory.count_item("wood"), 10)
	assert_eq(int(restored.stats.get("wood_collected", 0)), 7)
