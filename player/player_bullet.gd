extends Node2D

# Speed determines how many pixels the bullet will move per second
@export var speed: float = 1000

# Direction is the direction the bullet will move in
@export var direction: Vector2 = Vector2.RIGHT

func _ready():
  # Set the rotation of the bullet to the direction
  rotation = direction.angle()

func _process(delta: float) -> void:
  position += direction.normalized() * speed * delta
  # When outside the screen, destroy the bullet
  if position.x > 1000 or position.x < -1000 or position.y > 1000 or position.y < -1000:
    queue_free()
