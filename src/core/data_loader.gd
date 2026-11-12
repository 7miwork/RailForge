class_name DataLoader
extends RefCounted
## Lädt JSON-Daten (Ären, später Rezepte, Gebäude, Forschung) aus res://data/.

static func load_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Datei nicht lesbar: %s" % path)
		return null
	return JSON.parse_string(file.get_as_text())
