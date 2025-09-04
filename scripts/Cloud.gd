extends Node2D

@export var speed: float = 40.0
@export var scale_variation: float = 1.0
@export var debug: bool = true
@onready var poly: Polygon2D = $Polygon2D

const BLOB_NAME_PREFIX := "Blob_"

func _ready() -> void:
	z_index = -1 # ensure the whole cloud node is above background
	_build_cloud()
	if debug:
		print("[Cloud] ready path=", get_path(), " pos=", position, " speed=", speed, " scale_var=", scale_variation)

func configure(spd: float, scale_var: float) -> void:
	speed = spd
	scale_variation = scale_var
	_build_cloud()

func _build_cloud() -> void:
	# Clear old blob nodes if any
	for child in get_children():
		if child is Polygon2D and String(child.name).begins_with(BLOB_NAME_PREFIX):
			child.queue_free()

	# Base soft body (ellipse)
	var base_pts: PackedVector2Array = PackedVector2Array()
	var rx: float = 52.0 * scale_variation
	var ry: float = 24.0 * scale_variation
	var segs: int = 48
	for i in range(segs):
		var a := TAU * float(i) / float(segs)
		base_pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	if is_instance_valid(poly):
		poly.polygon = base_pts
		poly.color = Color(1, 1, 1, 0.95)
		poly.z_index = -1

	# Add puffy blobs to make a stylized cloud
	var blob_count: int = randi_range(4, 6)
	var span: float = rx * 1.4
	for i in range(blob_count):
		var cx: float = lerpf(-span * 0.5, span * 0.5, float(i) / float(max(1, blob_count - 1))) + randf_range(-8.0, 8.0)
		var cy: float = randf_range(-ry * 0.3, ry * 0.1)
		var r: float = randf_range(18.0, 30.0) * scale_variation
		var circle: PackedVector2Array = _circle_points(r, 32)
		var blob: Polygon2D = Polygon2D.new()
		blob.name = BLOB_NAME_PREFIX + str(i)
		blob.polygon = circle
		blob.color = Color(1, 1, 1, randf_range(0.88, 1.0))
		blob.position = Vector2(cx, cy)
		blob.z_index = -1
		add_child(blob)

	if debug:
		print("[Cloud] built base pts=", base_pts.size(), " blobs=", blob_count)

func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	if debug and Time.get_ticks_msec() % 1000 < 16:
		print("[Cloud] drift pos=", position)
	if position.x < -200.0:
		queue_free()

func debug_pin(pos: Vector2) -> void:
	# Forcefully make this cloud visible and stationary on screen for debugging
	position = pos
	speed = 0.0
	z_index = 10
	if is_instance_valid(poly):
		poly.color = Color(1, 0, 1, 1) # magenta
		poly.z_index = 10
	# Also recolor blobs
	for child in get_children():
		if child is Polygon2D and String(child.name).begins_with(BLOB_NAME_PREFIX):
			child.color = Color(1, 0, 1, 1)
			child.z_index = 10
	if debug:
		print("[Cloud] debug_pin at pos=", position, " z_index=", z_index)

func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(segments):
		var a := TAU * float(i) / float(segments)
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts
