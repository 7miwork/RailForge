extends GutTest
## Tests für Progress (Etappen-Fortschritt) und GameState (Save-Round-Trip).

var progress: Progress

func before_each() -> void:
	progress = Progress.new()

func test_current_stage_is_1_1() -> void:
	assert_eq(progress.current_stage().get("id"), "1.1")

func test_current_stage_id() -> void:
	assert_eq(progress.current_stage_id(), "1.1")

func test_mark_done_sets_flag() -> void:
	var stages: Array = progress.data.get("stages", [])
	assert_false(stages[0].get("done"))
	progress.mark_done("1.1")
	assert_true(stages[0].get("done"))
	assert_eq(progress.current_stage_id(), "1.2")

func test_game_state_roundtrip() -> void:
	var s := GameState.new()
	s.phase = 1
	s.stage = "1.1"
	s.stage_name = "Bewegung & Kamera"
	s.tick = 42
	s.era = 1

	var restored := GameState.from_dict(s.to_dict())
	assert_eq(restored.phase, 1)
	assert_eq(restored.stage, "1.1")
	assert_eq(restored.stage_name, "Bewegung & Kamera")
	assert_eq(restored.tick, 42)
	assert_eq(restored.era, 1)
