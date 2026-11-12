class_name Player
extends CharacterBody2D
## Spieler-Figur. Bewegung läuft über die Input-Map-Aktionen
## move_up/move_down/move_left/move_right (Tastatur UND virtueller Joystick).

@export var speed: float = 120.0
@export var world_size: Vector2 = Vector2(2000.0, 2000.0)

func _ready() -> void:
	# Platzhalter-Sprite: 16x16 farbiges Rechteck (echte Assets ab späteren Etappen).
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color("#2f5d2f"))
	$Sprite2D.texture = ImageTexture.create_from_image(image)

func _physics_process(_delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vec * speed
	move_and_slide()
	# Weltgrenzen (kein Wall-Clamping nötig, nur Position klemmen).
	position.x = clampf(position.x, 8.0, world_size.x - 8.0)
	position.y = clampf(position.y, 8.0, world_size.y - 8.0)
