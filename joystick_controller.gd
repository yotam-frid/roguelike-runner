extends Node2D

class_name JoystickController

signal pressed
signal released

@export var deadzone_radius: float = 3.0
@export var size_radius: float = 40.0

var is_pressed: bool = false
var is_moving: bool = false
var is_shooting: bool = false
var direction: Vector2 = Vector2.DOWN
var value_y: float = 0.0
var value_x: float = 0.0
var value: Vector2 = Vector2.ZERO
var moving_horizontal: bool = false

var _move_finger_index: int = -1
var _shoot_finger_index: int = -1

var _move_touch_origin: Vector2 = Vector2.ZERO
var _move_last_touch_position: Vector2 = Vector2.ZERO
var _move_turnaround_position: Vector2 = Vector2.ZERO

var _debug: bool = false

func _input(event: InputEvent) -> void:
	var is_move_event: bool = false
	var is_shoot_event: bool = false
	var viewport_width: float = get_viewport_rect().size.x

	if event is InputEventScreenTouch:
		# Check half of the screen width - left or right
		if event.position.x < viewport_width / 2:
			_move_finger_index = event.index
			is_move_event = true
			print("is move event: ", is_move_event)
			moving_horizontal = false
		else:
			_shoot_finger_index = event.index
			is_shoot_event = true

		if event.pressed:
			is_pressed = true
			emit_signal("pressed")
			# Moving
			if is_move_event:
				is_moving = true
				_move_touch_origin = event.position
				_move_last_touch_position = event.position
				_move_turnaround_position = event.position
				value_y = 0.0
				value_x = 0.0
				value = Vector2.ZERO
			# Shooting
			if is_shoot_event:
				is_shooting = true
		else:
			is_pressed = false
			emit_signal("released")

			# Moving
			if event.index == _move_finger_index:
				is_moving = false
				moving_horizontal = false
				_move_touch_origin = Vector2.ZERO
				_move_finger_index = -1
				value_y = 0.0
				value_x = 0.0
				value = Vector2.ZERO
			# Shooting
			if event.index == _shoot_finger_index:
				is_shooting = false
				_shoot_finger_index = -1

	elif event is InputEventScreenDrag:
		if event.index == _move_finger_index:
			value_y = clamp((event.position.y - _move_touch_origin.y) / size_radius, -1.0, 1.0)

			direction = Vector2.DOWN if value_y > 0.0 else Vector2.UP
			# Update turnaround position when moving in current direction
			if (direction == Vector2.UP and event.position.y < _move_last_touch_position.y) \
			or (direction == Vector2.DOWN and event.position.y > _move_last_touch_position.y):
				_move_turnaround_position = event.position
			# Check if we've turned around
			else:
				var distance = abs(event.position.y - _move_turnaround_position.y)
				if distance > deadzone_radius / 4:
					value_y = 0.0
					_move_touch_origin = _move_turnaround_position
				if abs(event.position.y - _move_turnaround_position.y) > deadzone_radius:
					# Turned around
					_move_touch_origin = _move_turnaround_position
					direction = Vector2.DOWN if direction == Vector2.UP else Vector2.UP
					
			# X-axis movement is not joystick like, but more ilke a trackpad
			if not moving_horizontal and abs(event.position.x - _move_last_touch_position.x) > deadzone_radius:
				moving_horizontal = true

			if moving_horizontal:
				var _move_x_bounds: float = viewport_width / 4
				value_x = clamp(event.position.x / _move_x_bounds, 0.0, 1.0)
				print("value_x: ", value_x)

			_move_last_touch_position = event.position
			value = Vector2(value_x, value_y)

	queue_redraw()

func _draw() -> void:
	if not _debug:
		return
	if is_moving:
		draw_circle(to_global(_move_touch_origin), deadzone_radius, Color.RED, false)
		draw_circle(to_global(_move_touch_origin), size_radius, Color.ALICE_BLUE, false)
		draw_circle(to_global(_move_turnaround_position), deadzone_radius, Color.GREEN, true)
		draw_string(ThemeDB.fallback_font, _move_touch_origin + Vector2.RIGHT * size_radius, str(value_y), 0, -1, 12, Color.BLACK)
