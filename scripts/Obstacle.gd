extends Area2D

signal exited_screen

@export var speed: float = 180.0
@export var shape_key: String = "square"
@export var size_scale: float = 1.0

@onready var poly: Polygon2D = $Polygon2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
    _apply_visual()

func configure(shape_key_in: String, size_scale_in: float, speed_in: float) -> void:
    shape_key = shape_key_in
    size_scale = size_scale_in
    speed = speed_in
    _apply_visual()

func _apply_visual() -> void:
    var pts: PackedVector2Array = Shapes.get_shape_points(shape_key, size_scale)
    if is_instance_valid(poly):
        poly.polygon = pts
        poly.color = Color.hex(0xffca28ff)
    if is_instance_valid(collision):
        collision.polygon = pts

func _physics_process(delta: float) -> void:
    position.x -= speed * delta
    if position.x < -200.0:
        emit_signal("exited_screen")
        queue_free()
