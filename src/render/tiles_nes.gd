class_name TilesNES
extends RefCounted
## Prozedurale NES-Texturen (16×16 Tiles, 16×16 Spieler) in Farbe.
## AUSSCHLIESSLICH Farben aus NES_PALETTE – keine anderen Töne,
## keine binären Assets. Alles deterministisch.

## NES-Palette (Auswahl klassischer NES-Farben, 18 Töne).
const NES_00 := Color("#000000") # schwarz
const NES_01 := Color("#1a1c2c") # dunkelblau-grau
const NES_02 := Color("#5d275d") # lila
const NES_03 := Color("#b13e53") # rot
const NES_04 := Color("#ef7d57") # orange
const NES_05 := Color("#ffcd75") # hellgel
const NES_06 := Color("#a7f070") # hellgrün
const NES_07 := Color("#38b764") # grün
const NES_08 := Color("#257179") # petrol
const NES_09 := Color("#29366f") # blau
const NES_10 := Color("#3b5dc9") # hellblau
const NES_11 := Color("#41a6f6") # himmelblau
const NES_12 := Color("#73eff7") # cyan
const NES_13 := Color("#f4f4f4") # fast weiß
const NES_14 := Color("#94b0c2") # grau
const NES_15 := Color("#566c86") # dunkelgrau
const NES_16 := Color("#333c57") # anthrazit

const NES_PALETTE: Array[Color] = [
	NES_00, NES_01, NES_02, NES_03, NES_04, NES_05, NES_06, NES_07,
	NES_08, NES_09, NES_10, NES_11, NES_12, NES_13, NES_14, NES_15,
	NES_16,
]

# Kurzreferenzen für lesbaren Code.
const BLACK := NES_00
const DKBLUE := NES_01
const PURPLE := NES_02
const RED := NES_03
const ORANGE := NES_04
const YELLOW := NES_05
const LGREEN := NES_06
const GREEN := NES_07
const TEAL := NES_08
const BLUE := NES_09
const LBLUE := NES_10
const SKY := NES_11
const CYAN := NES_12
const WHITE := NES_13
const GREY := NES_14
const DGREY := NES_15
const NAVY := NES_16
const DARK := NES_01

const WOOD_DARK := RED
const STONE := GREY
const STONE_DARK := DGREY
const IRON := LBLUE

static func _img(w: int, h: int, bg: Color) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(bg)
	return img

static func _tex(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

## 16×16 Gras-Tile: Himmelblau-Basis? Nein – Gras: GRAS-Grün mit Textur-Akzenten.
static func make_ground() -> ImageTexture:
	var img := _img(16, 16, GREEN)
	for y in 16:
		for x in 16:
			if (x * 7 + y * 13 + x * y) % 11 == 0:
				img.set_pixel(x, y, LGREEN)
	return _tex(img)

## 16×16 Baum: grüner Laubball mit braunem Stamm.
static func make_wood_node() -> ImageTexture:
	var img := _img(16, 16, GREEN)
	for y in range(2, 11):
		for x in range(3, 13):
			var dx := float(x - 8)
			var dy := float(y - 6) * 1.4
			if dx * dx + dy * dy <= 22.0:
				img.set_pixel(x, y, LGREEN if (x + y) % 3 == 0 else TEAL)
	for y in range(10, 16):
		for x in range(7, 9):
			img.set_pixel(x, y, WOOD_DARK)
	# Boden-Schatten
	for x in range(4, 12):
		img.set_pixel(x, 15, TEAL)
	return _tex(img)

## 16×16 Fels: grau mit dunkler Schattierung.
static func make_stone_node() -> ImageTexture:
	var img := _img(16, 16, GREEN)
	for y in range(5, 15):
		for x in range(3, 13):
			var dx := float(x - 8)
			var dy := float(y - 10) * 1.6
			if dx * dx + dy * dy <= 18.0:
				img.set_pixel(x, y, STONE if (x * 3 + y) % 4 else DGREY)
	for x in range(4, 12):
		img.set_pixel(x, 13, STONE_DARK)
	img.set_pixel(7, 12, STONE_DARK)
	img.set_pixel(9, 11, STONE_DARK)
	return _tex(img)

## 16×16 Eisenerz: Fels mit blauen Erz-Kristallen.
static func make_iron_node() -> ImageTexture:
	var img := make_stone_node().get_image()
	for pos in [Vector2i(6, 6), Vector2i(9, 5), Vector2i(11, 8), Vector2i(5, 9), Vector2i(8, 8)]:
		img.set_pixel(pos.x, pos.y, IRON)
	img.set_pixel(6, 6, CYAN)
	img.set_pixel(9, 5, CYAN)
	return _tex(img)

## 16×16 Spieler (NES-maßig eine Kachel): rote Kappe, Hautfarbe, blaue Hose.
static func make_player() -> ImageTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in 16:
		for x in 16:
			var edge := x == 0 or x == 15 or y == 0 or y == 15
			var corner := (x == 0 or x == 15) and (y == 0 or y == 15)
			if corner:
				continue
			elif edge:
				img.set_pixel(x, y, NAVY)
			elif y <= 6:
				img.set_pixel(x, y, RED) # Kappe
			elif y <= 9:
				img.set_pixel(x, y, YELLOW) # Gesicht
			elif y <= 12:
				img.set_pixel(x, y, LBLUE) # Shirt
			else:
				img.set_pixel(x, y, BLUE) # Hose
	# Augen
	img.set_pixel(5, 7, NAVY)
	img.set_pixel(10, 7, NAVY)
	return _tex(img)
