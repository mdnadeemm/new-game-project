extends Resource

class_name Shapes

static func make_regular_polygon(sides: int, radius: float) -> PackedVector2Array:
    var pts := PackedVector2Array()
    for i in range(sides):
        var angle := -PI / 2.0 + TAU * float(i) / float(sides)
        pts.append(Vector2(cos(angle), sin(angle)) * radius)
    return pts

static func get_shape_points(shape_key: String, size_scale: float) -> PackedVector2Array:
    var radius := 30.0 * size_scale
    match shape_key:
        "triangle":
            return make_regular_polygon(3, radius)
        "square":
            return make_regular_polygon(4, radius)
        "pentagon":
            return make_regular_polygon(5, radius)
        "hexagon":
            return make_regular_polygon(6, radius)
        _:
            return make_regular_polygon(4, radius)

static func all_shapes() -> Array[String]:
    return ["triangle", "square", "pentagon", "hexagon"]

static func size_scales() -> Array[float]:
    return [0.8, 1.0, 1.3]
