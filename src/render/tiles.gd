class_name Tiles
extends RefCounted
## Prozedurale Game-Boy-Texturen (16×16 Tiles, 8×8 Spieler).
## AUSSCHLIESSLICH die 4 GB-Farben – keine anderen Töne, keine binären Assets.
## Alles deterministisch (keine ungeseedeten Random-Werte).

const GB_DARKEST := Color("#0f380f")
const GB_DARK := Color("#306230")
const GB_LIGHT := Color("#8bac0f")
const GB_LIGHTEST := Color("#9bbc0f")

static func _img(w: int, h: int, bg: Color) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(bg)
	return img

static func _tex(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

## 16×16 Gras-Tile: GB_LIGHT-Basis mit deterministischen GB_LIGHTEST-Akzenten.
static func make_ground() -> ImageTexture:
	var img := _img(16, 16, GB_LIGHT)
	for y in 16:
		for x in 16:
			if (x * 7 + y * 13 + x * y) % 11 == 0:
				img.set_pixel(x, y, GB_LIGHTEST)
	return _tex(img)

## 16×16 Baum: GB_DARK-Krone auf GB_LIGHT, GB_DARKEST-Stamm.
static func make_wood_node() -> ImageTexture:
	var img := _img(16, 16, GB_LIGHT)
	for y in range(2, 11):
		for x in range(3, 13):
			var dx := float(x - 8)
			var dy := float(y - 6) * 1.4
			if dx * dx + dy * dy <= 22.0:
				img.set_pixel(x, y, GB_DARK)
	for y in range(10, 16):
		for x in range(7, 9):
			img.set_pixel(x, y, GB_DARKEST)
	return _tex(img)

## 16×16 Fels: GB_DARK-Fels mit GB_DARKEST-Schattierung.
static func make_stone_node() -> ImageTexture:
	var img := _img(16, 16, GB_LIGHT)
	for y in range(5, 15):
		for x in range(3, 13):
			var dx := float(x - 8)
			var dy := float(y - 10) * 1.6
			if dx * dx + dy * dy <= 18.0:
				img.set_pixel(x, y, GB_DARK)
	for x in range(4, 12):
		img.set_pixel(x, 13, GB_DARKEST)
	img.set_pixel(7, 12, GB_DARKEST)
	img.set_pixel(9, 11, GB_DARKEST)
	return _tex(img)

## 16×16 Eisenerz: GB_DARK-Fels mit GB_DARKEST-Erz-Kristallen.
static func make_iron_node() -> ImageTexture:
	var img := make_stone_node().get_image()
	for pos in [Vector2i(6, 6), Vector2i(9, 5), Vector2i(11, 8), Vector2i(5, 9), Vector2i(8, 8)]:
		img.set_pixel(pos.x, pos.y, GB_DARKEST)
	return _tex(img)

## 8×8 Spieler: GB_DARKEST-Körper, GB_LIGHTEST-Outline, transparente Ecken.
static func make_player() -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in 8:
		for x in 8:
			var corner := (x == 0 or x == 7) and (y == 0 or y == 7)
			var edge := x == 0 or x == 7 or y == 0 or y == 7
			if corner:
				continue # transparent
			elif edge:
				img.set_pixel(x, y, GB_LIGHTEST)
			else:
				img.set_pixel(x, y, GB_DARKEST)
	# „Augen" in GB_LIGHT
	img.set_pixel(2, 3, GB_LIGHT)
	img.set_pixel(5, 3, GB_LIGHT)
	return _tex(img)
