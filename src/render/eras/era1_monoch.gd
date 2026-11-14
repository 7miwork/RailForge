class_name Era1Monoch
extends EraRenderer
## Renderer für Ära 1 (Monochrom / Game Boy).
## Game-Boy-Palette (4 Farben), 160×144-SubViewport, prozedurale Tiles.
## Der Ära-Tausch läuft über EraManager; EraTransition ist dort zu finden.

const GB_DARKEST := Color("#0f380f")
const GB_DARK := Color("#306230")
const GB_LIGHT := Color("#8bac0f")
const GB_LIGHTEST := Color("#9bbc0f")

func get_palette() -> Array[Color]:
	return [GB_DARKEST, GB_DARK, GB_LIGHT, GB_LIGHTEST]

func get_backdrop_color() -> Color:
	return GB_LIGHT

func mount(parent: Node) -> void:
	parent.add_child(self)
	# Root-Viewport-Clear = schwarz (Letterbox); die Welt selbst nutzt
	# GB_LIGHT als Backdrop-Farbe im SubViewport.
	RenderingServer.set_default_clear_color(Color.BLACK)
