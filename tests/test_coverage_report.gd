extends GutTest
## Coverage-Report: Jede Datei in src/core/, src/render/ (inkl. eras/),
## src/world/ und src/player/ muss eine zugehörige Test-Datei
## tests/test_<name>.gd haben. Schlägt fehl, wenn eine
## Datei ohne Test gefunden wird. (src/ui ist ausgenommen – dünne UI-Schicht.)

const COVERED_DIRS: Array[String] = [
	"res://src/core",
	"res://src/render",
	"res://src/render/eras",
	"res://src/world",
	"res://src/player",
]

func _collect_gd_files(dir_path: String, recursive_subdirs: Array[String] = []) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return result
	for file_name in dir.get_files():
		if file_name.ends_with(".gd"):
			result.append("%s/%s" % [dir_path, file_name])
	for sub in dir.get_directories():
		var sub_path := "%s/%s" % [dir_path, sub]
		if recursive_subdirs.has(sub_path):
			for f in _collect_gd_files(sub_path, recursive_subdirs):
				result.append(f)
	return result

func test_every_source_file_has_test() -> void:
	var missing: Array[String] = []
	for dir_path in COVERED_DIRS:
		for file_path in _collect_gd_files(dir_path, COVERED_DIRS):
			var base := file_path.get_file().trim_suffix(".gd")
			var test_path := "res://tests/test_%s.gd" % base
			if not FileAccess.file_exists(test_path):
				missing.append(file_path)
	assert_eq(missing, [], "Dateien ohne Test: %s" % str(missing))
