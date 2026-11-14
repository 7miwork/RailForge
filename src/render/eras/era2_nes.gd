class_name Era2Nes
extends EraRenderer
## Renderer für Ära 2 (8-Bit-Farbe / NES).
## NES-Palette (~18 Farben), 256×240-SubViewport, prozedurale Farb-Tiles.
## Der eigentliche Ära-Tausch läuft über EraManager; dieser Renderer
## liefert Palette und Backdrop-Farbe.

func get_palette() -> Array[Color]:
	return TilesNES.NES_PALETTE

func get_backdrop_color() -> Color:
	# Himmelblau als Welt-Hintergrund in der NES-Ära.
	return TilesNES.SKY

func mount(parent: Node) -> void:
	parent.add_child(self)
