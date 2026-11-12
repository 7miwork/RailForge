class_name ItemDB
extends RefCounted
## Statische Item-Datenbank. Lädt data/items.json lazy beim ersten Zugriff.

static var _items: Dictionary = {}

static func _ensure_loaded() -> void:
	if _items.is_empty():
		var loaded: Variant = DataLoader.load_json("res://data/items.json")
		if loaded is Dictionary:
			_items = loaded

static func load_items(path: String = "res://data/items.json") -> void:
	var loaded: Variant = DataLoader.load_json(path)
	_items = loaded if loaded is Dictionary else {}

static func get_item(item_id: String) -> Dictionary:
	_ensure_loaded()
	return _items.get(item_id, {})

static func max_stack(item_id: String) -> int:
	return int(get_item(item_id).get("stack", 99))

static func display_name(item_id: String) -> String:
	return str(get_item(item_id).get("name", item_id))

static func color(item_id: String) -> Color:
	return Color(str(get_item(item_id).get("color", "#ffffff")))
