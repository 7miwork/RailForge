class_name CraftingUI
extends CanvasLayer
## Crafting-UI: Liste aller Rezepte (freigeschaltet + gesperrt),
## Kostenanzeige, Craft-Button pro Rezept. Per "crafting_toggle" (C / Touch)
## ein-/ausblendbar. Startet ausgeblendet. Game-Boy-Palette.

signal crafted(recipe_id: String)

var game_state: GameState

var _vbox: VBoxContainer

func _ready() -> void:
	add_to_group("crafting_ui")
	_vbox = $Panel/Scroll/VBox
	$Panel.add_theme_stylebox_override("panel", GBStyle.panel())
	visible = false

func bind(p_state: GameState) -> void:
	game_state = p_state
	refresh()

func _process(_delta: float) -> void:
	# Polling statt _unhandled_input: Touch-Button nutzt Input.action_press().
	# Während der Ära-Transition ist die Eingabe gesperrt.
	if EraTransition.input_locked:
		return
	if Input.is_action_just_pressed("crafting_toggle"):
		visible = not visible

func refresh() -> void:
	if game_state == null:
		return
	for child in _vbox.get_children():
		child.queue_free()
	for recipe: Dictionary in RecipeDB.all_recipes():
		_vbox.add_child(_build_row(recipe))

func _build_row(recipe: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var unlocked := RecipeDB.is_unlocked(recipe, game_state)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Tiles.GB_DARKEST if unlocked else Tiles.GB_DARK)
	label.add_theme_font_size_override("font_size", 10)
	label.text = _recipe_text(recipe, unlocked)
	row.add_child(label)

	var button := Button.new()
	button.text = "Craften"
	GBStyle.apply_button(button)
	button.disabled = not Crafting.can_craft(str(recipe.get("id", "")), game_state.inventory, game_state)
	button.pressed.connect(_on_craft_pressed.bind(str(recipe.get("id", ""))))
	row.add_child(button)
	return row

func _recipe_text(recipe: Dictionary, unlocked: bool) -> String:
	var output: Dictionary = recipe.get("output", {})
	var name := ItemDB.display_name(str(output.get("item_id", "")))
	var output_amount := int(output.get("amount", 1))
	var prefix := "%s" % name
	if output_amount > 1:
		prefix += " x%d" % output_amount

	var costs: Array[String] = []
	for input_entry: Dictionary in recipe.get("inputs", []):
		costs.append("%dx %s" % [int(input_entry.get("amount", 0)), ItemDB.display_name(str(input_entry.get("item_id", "")))])
	var cost_text := " (%s)" % ", ".join(costs) if not costs.is_empty() else ""

	if unlocked:
		return prefix + cost_text

	# Gesperrt: Hinweis, was noch abgebaut werden muss.
	var unlock: Dictionary = recipe.get("unlock", {})
	var hint := ""
	if str(unlock.get("type", "")) == "collected":
		hint = " – %dx %s abbauen" % [
			int(unlock.get("amount", 0)),
			ItemDB.display_name(str(unlock.get("item_id", ""))),
		]
	return "%s%s (gesperrt%s)" % [prefix, cost_text, hint]

func _on_craft_pressed(recipe_id: String) -> void:
	var result := Crafting.craft(recipe_id, game_state.inventory, game_state)
	if bool(result.get("ok", false)):
		crafted.emit(recipe_id)
	refresh()
