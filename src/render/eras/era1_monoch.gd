class_name Era1Monoch
extends EraRenderer
## Renderer für Ära 1 (Monochrom / Game Boy).
## Game-Boy-Palette (4 Farben), 160×144-SubViewport, prozedurale Tiles.
## EraTransition-Child ist vorbereitet; play_to_era() ist in Phase 1 noch No-op.

const GB_DARKEST := Color("#0f380f")
const GB_DARK := Color("#306230")
const GB_LIGHT := Color("#8bac0f")
const GB_LIGHTEST := Color("#9bbc0f")

var transition: EraTransition

func get_palette() -> Array[Color]:
	return [GB_DARKEST, GB_DARK, GB_LIGHT, GB_LIGHTEST]

func mount(parent: Node) -> void:
	parent.add_child(self)
	# Root-Viewport-Clear = schwarz (Letterbox); die Welt selbst nutzt
	# GB_LIGHT als Backdrop-Farbe im SubViewport.
	RenderingServer.set_default_clear_color(Color.BLACK)
	transition = EraTransition.new()
	transition.name = "EraTransition"
	add_child(transition)

func draw_state(_state: GameState) -> void:
	if not is_inside_tree():
		return
	var hud := get_tree().get_first_node_in_group("progress_hud") as ProgressHud
	if hud != null:
		hud.refresh()
	var inv_ui := get_tree().get_first_node_in_group("inventory_ui") as InventoryUI
	if inv_ui != null:
		inv_ui.refresh()
	var craft_ui := get_tree().get_first_node_in_group("crafting_ui") as CraftingUI
	if craft_ui != null:
		craft_ui.refresh()
	var debug_ui := get_tree().get_first_node_in_group("debug_overlay") as DebugOverlay
	if debug_ui != null:
		debug_ui.refresh_info()

func handle_input(_event: InputEvent) -> void:
	pass
