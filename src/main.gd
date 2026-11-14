extends Node
## Einstiegspunkt. Verdrahtet GameState (mit Save/Load), Progress,
## EraManager (Ära-Renderer + Übergänge), HUD, Inventar-UI, Crafting-UI,
## Debug-Overlay und Touch-Steuerung.
## Die Welt (Ground, Player, ResourceNodes, Camera2D) liegt im SubViewport
## von WorldView; EraManager passt Auflösung und Skins pro Ära an.

@onready var world_view: SubViewportContainer = $WorldView
@onready var player: Player = $WorldView/Viewport/World/Player
@onready var camera: Camera2D = $WorldView/Viewport/World/Camera2D
@onready var progress_hud: ProgressHud = $UI/ProgressHud
@onready var inventory_ui: InventoryUI = $UI/InventoryUI
@onready var crafting_ui: CraftingUI = $UI/CraftingUI
@onready var debug_overlay: DebugOverlay = $UI/DebugOverlay
@onready var touch_controls: TouchControls = $UI/TouchControls

var state: GameState
var era_manager: EraManager
var _last_stage_id := ""

func _ready() -> void:
	state = SaveManager.load_state()

	# EraManager mountet den Renderer passend zum Spielstand (Ära 1 oder
	# geladene Ära 2) und übernimmt spätere Wechsel mit Transition.
	era_manager = EraManager.new()
	era_manager.name = "EraManager"
	add_child(era_manager)
	era_manager.setup(world_view)
	era_manager.era_changed.connect(_on_era_visuals_changed)
	era_manager.mount_initial(state)

	progress_hud.setup(state)

	# Signal-Verdrahtung einmalig (unabhängig vom GameState).
	player.inventory_changed.connect(inventory_ui.refresh)
	crafting_ui.crafted.connect(_on_crafted)

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

	# Während der Ära-Transition ist die Eingabe gesperrt.
	if EraTransition.input_locked:
		return

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
	# Renderer an den (ggf. neu geladenen) Spielstand anpassen.
	if state.era != era_manager._current_era_id():
		era_manager.mount_initial(state)
	else:
		era_manager.state = state
	player.setup(state, self)
	inventory_ui.bind_inventory(state.inventory)
	crafting_ui.bind(state)
	debug_overlay.bind(state, self)
	progress_hud.setup(state)
	refresh_all_ui()

func refresh_all_ui() -> void:
	if era_manager.current_renderer != null:
		era_manager.current_renderer.draw_state(state)
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

## Nach jedem erfolgreichen Craft: Freischalt-Meilensteine prüfen
## (z. B. 5 Eisenbarren → Ära 2).
func _on_crafted(_recipe_id: String) -> void:
	inventory_ui.refresh()
	_check_era_milestones()

func _check_era_milestones() -> void:
	if era_manager.is_transitioning():
		return
	for era_id: int in EraUnlocks.pending_unlocks(state):
		if era_id > state.era:
			progress_hud.toast("Ära %d freigeschaltet!" % era_id)
			era_manager.change_era(era_id, state)
			return

## Vom EraManager nach einem (evtl. animierten) Ära-Tausch aufgerufen.
func _on_era_visuals_changed(_era_id: int) -> void:
	refresh_all_ui()

## Vom Debug-Overlay aufgerufen: echter Ära-Tausch (mit Transition).
## Ären ohne Renderer werden von EraManager ignoriert (Warning).
func on_era_changed(era_id: int) -> void:
	era_manager.change_era(era_id, state)

## Player fragt das während _physics_process ab (Eingabe-Lock).
func is_transitioning() -> bool:
	return era_manager != null and era_manager.is_transitioning()

func _on_debug_state_changed() -> void:
	refresh_all_ui()

func _on_debug_reset() -> void:
	state = GameState.new()
	_apply_state_to_ui()
	progress_hud.flash("Neues Spiel")

func world_size() -> Vector2:
	return player.world_size
