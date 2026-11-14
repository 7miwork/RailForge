class_name GBStyle
extends RefCounted
## Game-Boy-Palette für UI-Elemente. Nutzt ausschließlich die 4 GB-Farben
## aus Tiles (GB_DARKEST/DARK/LIGHT/LIGHTEST).

static func panel() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Tiles.GB_LIGHTEST
	s.border_color = Tiles.GB_DARKEST
	s.set_border_width_all(2)
	s.set_content_margin_all(8.0)
	return s

static func box(color: Color, border := true) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	if border:
		s.border_color = Tiles.GB_DARKEST
		s.set_border_width_all(1)
	return s

## Button im Game-Boy-Stil: hell → Hover, dunkel → Pressed, disabled gedimmt.
static func apply_button(btn: Button, bg: Color = Tiles.GB_LIGHT, fg: Color = Tiles.GB_DARKEST) -> void:
	btn.add_theme_stylebox_override("normal", box(bg))
	btn.add_theme_stylebox_override("hover", box(Tiles.GB_LIGHTEST))
	btn.add_theme_stylebox_override("pressed", box(Tiles.GB_DARK))
	btn.add_theme_stylebox_override("disabled", box(Tiles.GB_LIGHTEST))
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_color_override("font_pressed_color", Tiles.GB_LIGHTEST)
	btn.add_theme_color_override("font_disabled_color", Tiles.GB_DARK)
	btn.add_theme_font_size_override("font_size", 10)
