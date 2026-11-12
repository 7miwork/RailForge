class_name RecipeDB
extends RefCounted
## Statische Rezept-Datenbank. Lädt data/recipes.json lazy beim ersten Zugriff.

static var _recipes: Array = []

static func _ensure_loaded() -> void:
	if _recipes.is_empty():
		var loaded: Variant = DataLoader.load_json("res://data/recipes.json")
		if loaded is Array:
			_recipes = loaded

static func load_recipes(path: String = "res://data/recipes.json") -> void:
	var loaded: Variant = DataLoader.load_json(path)
	_recipes = loaded if loaded is Array else []

static func get_recipe(recipe_id: String) -> Dictionary:
	_ensure_loaded()
	for recipe: Dictionary in _recipes:
		if str(recipe.get("id", "")) == recipe_id:
			return recipe
	return {}

static func all_recipes() -> Array:
	_ensure_loaded()
	return _recipes

## Prüft Unlock-Bedingung gegen ein reines Stats-Dict (ohne GameState).
static func is_recipe_unlocked(recipe: Dictionary, stats: Dictionary) -> bool:
	var unlock: Dictionary = recipe.get("unlock", {})
	match str(unlock.get("type", "")):
		"start":
			return true
		"collected":
			var key := str(unlock.get("item_id", "")) + "_collected"
			return int(stats.get(key, 0)) >= int(unlock.get("amount", 0))
		_:
			return false

## Prüft, ob ein Rezept freigeschaltet ist (GameState-Variante).
static func is_unlocked(recipe: Dictionary, game_state: GameState) -> bool:
	return is_recipe_unlocked(recipe, game_state.stats)

## Rezept-IDs, die zwischen altem und neuem Stats-Stand NEU freigeschaltet wurden.
## "start"-Rezepte werden ignoriert (sie waren nie „gesperrt").
static func newly_unlocked(old_stats: Dictionary, new_stats: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for recipe: Dictionary in all_recipes():
		var unlock: Dictionary = recipe.get("unlock", {})
		if str(unlock.get("type", "")) != "collected":
			continue
		if not is_recipe_unlocked(recipe, old_stats) and is_recipe_unlocked(recipe, new_stats):
			result.append(str(recipe.get("id", "")))
	return result

static func unlocked_recipes(game_state: GameState) -> Array:
	var result: Array = []
	for recipe: Dictionary in all_recipes():
		if is_unlocked(recipe, game_state):
			result.append(recipe)
	return result
