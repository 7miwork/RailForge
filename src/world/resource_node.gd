class_name ResourceNode
extends Area2D
## Abbaubarer Ressourcen-Knoten (Holz, Stein, Eisenerz, …).
## Liegt auf Kollision-Layer 2, wird von der InteractionArea des Spielers erkannt.

@export var item_id: String = "wood"
@export var amount: int = 5
@export var amount_per_hit: int = 1

var _label: Label

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

	# Platzhalter-Sprite: 16x16 farbiges Rechteck in ItemDB-Farbe.
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(ItemDB.color(item_id))
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = ImageTexture.create_from_image(image)
	add_child(sprite)

	# Restmenge als kleiner Text über dem Knoten.
	_label = Label.new()
	_label.name = "AmountLabel"
	_label.position = Vector2(-8, -20)
	_label.add_theme_color_override("font_color", Color("#0f380f"))
	_label.add_theme_color_override("font_shadow_color", Color(1, 1, 1, 0.8))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(_label)
	_update_label()

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
