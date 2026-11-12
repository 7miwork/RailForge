class_name Inventory
extends RefCounted
## Inventar mit festen Slots. Jeder Slot ist ein Dictionary
## {"item_id": String, "amount": int} oder leer {}.
## Reine Logik (RefCounted), kein Rendering.

const MAX_SLOTS := 20

var slots: Array[Dictionary] = []

func _init() -> void:
	for i in MAX_SLOTS:
		slots.append({})

## Fügt Items hinzu: erst bestehende Stacks auffüllen, dann neue Slots.
## Gibt den Rest zurück, der nicht passte (0 = alles untergebracht).
func add_item(item_id: String, amount: int, max_stack: int) -> int:
	var remaining := amount
	for slot: Dictionary in slots:
		if remaining <= 0:
			break
		if slot.get("item_id") == item_id:
			var current := int(slot.get("amount", 0))
			var space := max_stack - current
			if space > 0:
				var add := mini(space, remaining)
				slot["amount"] = current + add
				remaining -= add
	for i in slots.size():
		if remaining <= 0:
			break
		if slots[i].is_empty():
			var add := mini(max_stack, remaining)
			slots[i] = {"item_id": item_id, "amount": add}
			remaining -= add
	return remaining

## Entfernt Items. Gibt die tatsächlich entfernte Menge zurück.
func remove_item(item_id: String, amount: int) -> int:
	var remaining := amount
	var removed := 0
	for slot: Dictionary in slots:
		if remaining <= 0:
			break
		if slot.get("item_id") == item_id:
			var current := int(slot.get("amount", 0))
			var take := mini(current, remaining)
			var left := current - take
			if left <= 0:
				slot.clear()
			else:
				slot["amount"] = left
			removed += take
			remaining -= take
	return removed

func count_item(item_id: String) -> int:
	var total := 0
	for slot: Dictionary in slots:
		if slot.get("item_id") == item_id:
			total += int(slot.get("amount", 0))
	return total

func has_item(item_id: String, amount: int) -> bool:
	return count_item(item_id) >= amount

func to_dict() -> Dictionary:
	return {"slots": slots.duplicate(true)}

static func from_dict(data: Dictionary) -> Inventory:
	var inv := Inventory.new()
	var saved: Array = data.get("slots", [])
	for i in mini(saved.size(), MAX_SLOTS):
		var s: Variant = saved[i]
		if s is Dictionary and s.has("item_id"):
			inv.slots[i] = {
				"item_id": str(s.get("item_id", "")),
				"amount": int(s.get("amount", 0)),
			}
	return inv
