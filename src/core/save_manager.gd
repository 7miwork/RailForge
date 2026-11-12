class_name SaveManager
extends RefCounted
## Speichern/Laden des GameState in user://save.json.
## Versioniert und defensiv: kaputte/zu neue Saves ergeben einen
## frischen GameState (kein Crash).

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := GameState.SAVE_VERSION

static func save(state: GameState) -> bool:
	var data := {
		"version": SAVE_VERSION,
		"saved_at": int(Time.get_unix_time_from_system()),
		"state": state.to_dict(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Speichern fehlgeschlagen: %s" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return true

static func load_state() -> GameState:
	if not exists():
		return GameState.new()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: Save nicht lesbar: %s" % SAVE_PATH)
		return GameState.new()
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(text) != OK:
		push_warning("SaveManager: Save enthält kein gültiges JSON")
		return GameState.new()
	var data: Variant = json.data
	if not data is Dictionary:
		push_warning("SaveManager: Save enthält kein JSON-Objekt")
		return GameState.new()

	var version := int(data.get("version", 0))
	if version > SAVE_VERSION:
		push_warning("SaveManager: Save-Version %d ist zu neu (max. %d)" % [version, SAVE_VERSION])
		return GameState.new()

	var state_dict: Variant = data.get("state", {})
	if not state_dict is Dictionary:
		push_warning("SaveManager: Save enthält keinen gültigen STATE")
		return GameState.new()
	return GameState.from_dict(state_dict)

static func exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func delete() -> bool:
	if not exists():
		return true
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH)) == OK

static func last_saved_at() -> int:
	if not exists():
		return 0
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return 0
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return 0
	var parsed: Variant = json.data
	file.close()
	if parsed is Dictionary:
		return int(parsed.get("saved_at", 0))
	return 0
