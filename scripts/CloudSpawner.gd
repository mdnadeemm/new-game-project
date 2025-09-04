extends Node2D

@export var min_delay: float = 1.5
@export var max_delay: float = 3.5
@export var min_speed: float = 25.0
@export var max_speed: float = 60.0
@export var min_scale: float = 0.7
@export var max_scale: float = 1.4
@export var debug: bool = true

var t := 0.0
var next_spawn := 0.0

func _ready() -> void:
    randomize()
    set_process(true)
    _spawn_cloud() # spawn one slightly off-screen right
    _spawn_cloud_on_screen() # also spawn one on screen immediately
    _spawn_pinned_debug_cloud()
    _plan_next()
    if debug:
        var rect := get_viewport_rect()
        print("[CloudSpawner] ready at:", get_path(), " rect=", rect)

func _process(delta: float) -> void:
    t += delta
    if t >= next_spawn:
        t = 0.0
        _spawn_cloud()
        _plan_next()
        if debug:
            print("[CloudSpawner] scheduled next spawn in ", next_spawn, "s; children=", get_child_count())

func _plan_next() -> void:
    next_spawn = randf_range(min_delay, max_delay)

func _spawn_cloud() -> void:
    var scene: PackedScene = preload("res://scenes/Cloud.tscn")
    var c: Node2D = scene.instantiate()
    add_child(c)
    var rect := get_viewport_rect()
    var max_y: float = max(60.0, rect.size.y * 0.6) # upper ~60%
    var y: float = clamp(randf_range(30.0, max_y), 30.0, rect.size.y - 80.0)
    c.position = Vector2(rect.size.x + 100.0, y)
    if c.has_method("configure"):
        c.call("configure", randf_range(min_speed, max_speed), randf_range(min_scale, max_scale))
    if c.has_method("set"):
        c.set("debug", debug)
    if debug:
        print("[CloudSpawner] _spawn_cloud pos=", c.position)

func _spawn_cloud_on_screen() -> void:
    var scene: PackedScene = preload("res://scenes/Cloud.tscn")
    var c: Node2D = scene.instantiate()
    add_child(c)
    var rect := get_viewport_rect()
    var max_y: float = max(60.0, rect.size.y * 0.55)
    var y: float = randf_range(30.0, max_y)
    c.position = Vector2(rect.size.x - 150.0, y)
    if c.has_method("configure"):
        c.call("configure", randf_range(min_speed, max_speed), randf_range(min_scale, max_scale))
    if c.has_method("set"):
        c.set("debug", debug)
    if debug:
        print("[CloudSpawner] _spawn_cloud_on_screen pos=", c.position)

func _spawn_pinned_debug_cloud() -> void:
    var scene: PackedScene = preload("res://scenes/Cloud.tscn")
    var c: Node2D = scene.instantiate()
    add_child(c)
    if c.has_method("configure"):
        c.call("configure", 0.0, 1.2)
    if c.has_method("debug_pin"):
        var rect := get_viewport_rect()
        c.call("debug_pin", Vector2(rect.size.x * 0.5, rect.size.y * 0.2))
    if c.has_method("set"):
        c.set("debug", debug)
    if debug:
        print("[CloudSpawner] _spawn_pinned_debug_cloud created")
