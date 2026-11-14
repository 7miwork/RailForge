class_name ResourceNode
extends Area2D
## Abbaubarer Ressourcen-Knoten (Holz, Stein, Eisenerz, …).
## Liegt auf Kollision-Layer 2, wird von der InteractionArea des Spielers erkannt.
## Sprite: prozedurales 16×16-Tile aus Tiles (Game-Boy-Optik).

@export var item_id: String = "wood"
@export var amount: int = 5
@export var amount_per_hit: int = 1

var _label: Label

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = _texture_for_item(item_id)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

	# Restmenge als kleiner Text über dem Knoten (Game-Boy-Farben).
	_label = Label.new()
	_label.name = "AmountLabel"
	_label.position = Vector2(-8, -18)
	_label.add_theme_color_override("font_color", Tiles.GB_DARKEST)
	_label.add_theme_color_override("font_shadow_color", Tiles.GB_LIGHTEST)
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	_label.add_theme_font_size_override("font_size", 8)
	add_child(_label)
	_update_label()

func _texture_for_item(id: String) -> Texture2D:
	match id:
		"wood":
			return Tiles.make_wood_node()
		"stone":
			return Tiles.make_stone_node()
		"iron_ore":
			return Tiles.make_iron_node()
		_:
			return Tiles.make_ground()

func mine() -> Dictionary:
	if is_depleted():
		return {}
	var grant := mini(amount_per_hit, amount)
	amount -= grant
	_update_label()
	return {"item_id": item_id, "amount": grant}

func is_depleted() -> bool:
	return amount <= 0

func _update_label() -> void:
	if _label != null:
		_label.text = str(amount)
