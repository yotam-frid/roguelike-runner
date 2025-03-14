extends Node2D

@export var drag_power: float = 1.0

var is_dragging: bool = false

func _ready():
  pass

func _input(event: InputEvent) -> void:
  if event is InputEventScreenTouch:
    if event.pressed:
      is_dragging = true
    else:
      is_dragging = false
  elif event is InputEventScreenDrag:
    if is_dragging:
      position += event.relative * drag_power