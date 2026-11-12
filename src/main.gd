extends Node
## Einstiegspunkt. Verdrahtet GameState (mit Save/Load), Progress,
## Ära-Renderer, HUD, Inventar-UI, Crafting-UI, Debug-Overlay und Touch-Steuerung.

@onready var world: Node2D = $World
@onready var player: Player = $World/Player
@onready var camera: Camera2D = $Camera2D
@onready var progress_hud: ProgressHud = $UI/ProgressHud
@onready var inventory_ui: InventoryUI = $UI/InventoryUI
@onready var crafting_ui: CraftingUI = $UI/CraftingUI
@onready var debug_overlay: DebugOverlay = $UI/DebugOverlay
@onready var touch_controls: TouchControls = $UI/TouchControls

var state: GameState
var renderer: EraRenderer
var _last_stage_id := ""

func _ready() -> void:
	state = SaveManager.load_state()

	renderer = Era1Monoch.new()
	renderer.mount(self)

	progress_hud.setup(state)

	# Signal-Verdrahtung einmalig (unabhängig vom GameState).
	player.inventory_changed.connect(inventory_ui.refresh)
	crafting_ui.crafted.connect(func(_id: String) -> void: inventory_ui.refresh())

	_apply_state_to_ui()

	# Debug-Overlay-Verdrahtung.
	debug_overlay.bind(state, self)
	debug_overlay.era_changed.connect(on_era_changed)
	debug_overlay.state_changed.connect(_on_debug_state_changed)
	debug_overlay.reset_requested.connect(_on_debug_reset)

	if SaveManager.exists():
		progress_hud.flash("Spielstand geladen")
	else:
		progress_hud.flash("Neues Spiel")

	# Spieler startet in der Mitte der Welt, Kamera darauf.
	player.position = world_size() * 0.5
	camera.position = player.position
	_last_stage_id = Progress.current_stage_id()

func _process(_delta: float) -> void:
	camera.position = player.position

	# Etappen-Wechsel-Toast (z. B. nach Debug-Markierung).
	var current_id := Progress.current_stage_id()
	if current_id != _last_stage_id:
		if _last_stage_id != "":
			progress_hud.toast("Etappe %s abgeschlossen" % _last_stage_id)
		_last_stage_id = current_id

	# Polling statt _unhandled_input: Touch-Buttons nutzen Input.action_press().
	if Input.is_action_just_pressed("save_game"):
		if SaveManager.save(state):
			progress_hud.flash("Gespeichert")
		else:
			progress_hud.flash("Speichern fehlgeschlagen")
	elif Input.is_action_just_pressed("load_game"):
		_load_game()
	elif Input.is_action_just_pressed("debug_toggle"):
		debug_overlay.toggle()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			SaveManager.save(state)
			get_tree().quit()
		NOTIFICATION_APPLICATION_PAUSED:
			# Mobile: Auto-Save beim Verlassen der App.
			SaveManager.save(state)

func _load_game() -> void:
	state = SaveManager.load_state()
	_apply_state_to_ui()
	progress_hud.flash("Geladen" if SaveManager.exists() else "Kein Save gefunden")

func _apply_state_to_ui() -> void:
	player.setup(state, self)
	inventory_ui.bind_inventory(state.inventory)
	crafting_ui.bind(state)
	debug_overlay.bind(state, self)
	progress_hud.setup(state)
	refresh_all_ui()

func refresh_all_ui() -> void:
	renderer.draw_state(state)
	inventory_ui.refresh()
	crafting_ui.refresh()
	debug_overlay.refresh_info()

## Vom Player nach jedem Abbau aufgerufen (enthält before/after_stats).
func on_resource_mined(result: Dictionary) -> void:
	var before: Dictionary = result.get("before_stats", {})
	var after: Dictionary = result.get("after_stats", {})
	for recipe_id: String in RecipeDB.newly_unlocked(before, after):
		var recipe := RecipeDB.get_recipe(recipe_id)
		var item_id := str(recipe.get("output", {}).get("item_id", ""))
		progress_hud.toast("Freigeschaltet: %s" % ItemDB.display_name(item_id))

func on_era_changed(era_id: int) -> void:
	# In Etappe 1.5 nur Spielstand-Feld + Log; echter Renderer-Tausch
	# kommt in späteren Phasen.
	state.era = era_id
	print("Debug: Ära gewechselt zu %d" % era_id)
	progress_hud.flash("Ära %d (Debug)" % era_id)

func _on_debug_state_changed() -> void:
	refresh_all_ui()

func _on_debug_reset() -> void:
	state = GameState.new()
	_apply_state_to_ui()
	progress_hud.flash("Neues Spiel")

func world_size() -> Vector2:
	return player.world_size
