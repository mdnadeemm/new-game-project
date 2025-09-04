extends Node2D

@export var sky_color: Color = Color(0.53, 0.81, 0.98, 1.0) # light blue
@export var ground_color: Color = Color(0.29, 0.63, 0.34, 1.0) # green
@export var ground_height: float = 120.0

@onready var sky: Polygon2D = $Sky
@onready var ground: Polygon2D = $Ground

func _ready() -> void:
    _update_background()

func _update_background() -> void:
    var rect := get_viewport_rect()
    var w: float = rect.size.x
    var h: float = rect.size.y
    var sky_poly: PackedVector2Array = PackedVector2Array([Vector2(0,0), Vector2(w,0), Vector2(w,h), Vector2(0,h)])
    var ground_top: float = max(0.0, h - ground_height)
    var ground_poly: PackedVector2Array = PackedVector2Array([Vector2(0,ground_top), Vector2(w,ground_top), Vector2(w,h), Vector2(0,h)])
    if is_instance_valid(sky):
        sky.polygon = sky_poly
        sky.color = sky_color
    sky.z_index = -10
    if is_instance_valid(ground):
        ground.polygon = ground_poly
        ground.color = ground_color
    ground.z_index = -5
