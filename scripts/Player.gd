extends Area2D

signal shape_changed(new_shape: String, size_scale: float)

@onready var poly: Polygon2D = $Polygon2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

var current_shape: String = "square"
var size_index: int = 1 # 0..len-1
var lives: int = 3
@export var move_speed: float = 300.0

func _ready() -> void:
    _apply_shape()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
        _cycle_shape(event.is_action_pressed("move_down"))
    elif event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
        _cycle_size(event.is_action_pressed("move_left"))

func _process(delta: float) -> void:
    var dir := Vector2.ZERO
    if Input.is_key_pressed(KEY_UP):
        dir.y -= 1
    if Input.is_key_pressed(KEY_DOWN):
        dir.y += 1
    if Input.is_key_pressed(KEY_LEFT):
        dir.x -= 1
    if Input.is_key_pressed(KEY_RIGHT):
        dir.x += 1
    if dir != Vector2.ZERO:
        dir = dir.normalized()
        position += dir * move_speed * delta
        var rect := get_viewport_rect()
        position.x = clamp(position.x, 20.0, rect.size.x - 20.0)
        position.y = clamp(position.y, 20.0, rect.size.y - 20.0)

func _cycle_shape(reverse: bool) -> void:
    var shapes := Shapes.all_shapes()
    var idx := shapes.find(current_shape)
    if idx == -1:
        idx = 0
    idx += -1 if reverse else 1
    idx = wrapi(idx, 0, shapes.size())
    current_shape = shapes[idx]
    _apply_shape()

func _cycle_size(reverse: bool) -> void:
    var sizes := Shapes.size_scales()
    size_index += -1 if reverse else 1
    size_index = wrapi(size_index, 0, sizes.size())
    _apply_shape()

func _apply_shape() -> void:
    var sizes := Shapes.size_scales()
    var size_scale: float = sizes[size_index]
    var pts: PackedVector2Array = Shapes.get_shape_points(current_shape, size_scale)
    if is_instance_valid(poly):
        poly.polygon = pts
        poly.color = Color.hex(0x42a5f5ff)
    if is_instance_valid(collision):
        collision.polygon = pts
    emit_signal("shape_changed", current_shape, size_scale)
