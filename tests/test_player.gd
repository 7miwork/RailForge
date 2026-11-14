extends GutTest
## Basis-Test für Player (Node; Bewegungs-Input wird manuell getestet).

func test_player_defaults() -> void:
	var p := Player.new()
	assert_eq(p.speed, 120.0)
	assert_eq(p.world_size, Vector2(2000, 2000))
	assert_true(p is CharacterBody2D)
	p.free()

func test_player_scene_loads() -> void:
	var packed := load("res://scenes/player.tscn") as PackedScene
	assert_not_null(packed)
	var p := packed.instantiate()
	add_child(p)
	assert_not_null(p.get_node_or_null("Sprite2D"))
	assert_not_null(p.get_node_or_null("InteractionArea"))
	p.free()
