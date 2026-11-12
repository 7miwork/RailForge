extends GutTest
## Tests für DataLoader (JSON-Laden, Fehlerfall).

func test_load_json_valid() -> void:
	var data: Variant = DataLoader.load_json("res://data/progress.json")
	assert_true(data is Dictionary)
	assert_true(data.has("stages"))

func test_load_json_array() -> void:
	var data: Variant = DataLoader.load_json("res://data/items.json")
	assert_true(data is Dictionary)
	assert_true(data.has("wood"))

func test_load_json_missing_file_returns_null() -> void:
	var data: Variant = DataLoader.load_json("res://data/does_not_exist.json")
	assert_null(data)
