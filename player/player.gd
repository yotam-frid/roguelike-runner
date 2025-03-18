extends CharacterBody2D

@export var joystick: JoystickController
@export var speed: float = 500.0
@export var turn_speed: float = 15.0 # Controls how quickly the player turns around

var shoot_cooldown: float = 0.0
var shoot_cooldown_max: float = 0.1

@onready var y_speed_curve: Curve = preload("res://player/y_speed_curve.tres")
@onready var bullet_scene: PackedScene = preload("res://player/player_bullet.tscn")

func _ready() -> void:
	joystick.pressed.connect(on_joystick_pressed)
	joystick.released.connect(on_joystick_released)

var _move_strength: float = 0.0
var _current_velocity: Vector2 = Vector2.ZERO

func on_joystick_pressed() -> void:
	print("Joystick pressed")

func on_joystick_released() -> void:
	print("Joystick released")
	# _move_direction = Vector2.ZERO

func on_joystick_moving(value: float) -> void:
	_move_strength = clamp(_move_strength + value, -1.0, 1.0)

func _process(delta: float) -> void:
	var y_value: float = y_speed_curve.sample(abs(joystick.value.y)) * sign(joystick.value.y)
	var target_velocity = speed * Vector2.DOWN * y_value
	
	# Gradually interpolate current_velocity toward target_velocity
	_current_velocity = _current_velocity.lerp(target_velocity, turn_speed * delta)
	
	velocity = _current_velocity
	move_and_slide()
	
	if joystick.moving_horizontal:
		var target_position_x: float = lerp(50, 200, joystick.value.x)
		position.x += (target_position_x - position.x) * turn_speed * delta

	if joystick.is_shooting:
		print("Shooting")
		shoot_cooldown = max(shoot_cooldown - delta, 0.0)
		if shoot_cooldown <= 0.0:
			var bullet = bullet_scene.instantiate()
			bullet.position = position + Vector2.RIGHT * ($ShipSprite.texture.get_width())
			get_tree().current_scene.add_child(bullet)
			shoot_cooldown = shoot_cooldown_max
# func _draw() -> void:
#   draw_string(Vector2.ZERO, "Hello, world!")
