class_name Era1Monoch
extends EraRenderer
## Renderer für Ära 1 (Monochrom / Game Boy).
## In Etappe 1.2: Mechanik (Abbau, Inventar) + HUD/Inventar-UI-Anbindung.
## Game-Boy-Optik (4 Grünstufen, Tiles) kommt in Etappe 1.6.

func mount(parent: Node) -> void:
	parent.add_child(self)
	RenderingServer.set_default_clear_color(Color("#8bac0f"))

func draw_state(_state: GameState) -> void:
	if not is_inside_tree():
		return
	var hud := get_tree().get_first_node_in_group("progress_hud") as ProgressHud
	if hud != null:
		hud.refresh()
	var inv_ui := get_tree().get_first_node_in_group("inventory_ui") as InventoryUI
	if inv_ui != null:
		inv_ui.refresh()

func handle_input(_event: InputEvent) -> void:
	pass
