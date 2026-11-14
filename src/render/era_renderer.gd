class_name EraRenderer
extends Node
## Basisklasse für Ära-Renderer. Jede Ära (src/render/eras/) erbt hiervon.
## Ein Ära-Wechsel tauscht nur den Renderer, der Spielstand bleibt.
## Jede Ära liefert ihre Farbpalette über get_palette() (für Übergänge/Tests).

## Die Palette der Ära (Standard: leer, wird pro Ära überschrieben).
func get_palette() -> Array[Color]:
	return []

## Hintergrundfarbe der Welt (Backdrop), Standard: aus Palette ableiten.
func get_backdrop_color() -> Color:
	var palette := get_palette()
	if palette.size() > 2:
		return palette[2]
	return palette[0] if not palette.is_empty() else Color.GRAY

func mount(_parent: Node) -> void:
	pass

## Standard-Implementierung: refreshed HUD, Inventar, Crafting, Debug.
## Ären können das überschreiben, müssen es aber nicht.
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

func unmount() -> void:
	queue_free()
