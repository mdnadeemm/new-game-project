extends Node2D

@onready var player: Area2D = $Player
@onready var hud_score: Label = $CanvasLayer/HUD/Score
@onready var hud_lives: Label = $CanvasLayer/HUD/Lives
@onready var hud_time: Label = $CanvasLayer/HUD/Time

var score: int = 0
var lives: int = 3
var time_accum := 0.0
@export var spawn_interval: float = 1.2
@export var obstacle_speed: float = 220.0

# Countdown timer (seconds)
var countdown: float = 6.0
const COUNTDOWN_BONUS: float = 6.0

func _ready() -> void:
	randomize()
	_update_hud()
	_update_time_label()

func _process(delta: float) -> void:
	time_accum += delta
	if time_accum >= spawn_interval:
		time_accum = 0.0
		_spawn_obstacle()

	# Countdown ticking
	countdown -= delta
	if countdown <= 0.0:
		_handle_timeout()
	else:
		_update_time_label()

func _spawn_obstacle() -> void:
	var scene := load("res://scenes/Obstacle.tscn") as PackedScene
	var o := scene.instantiate() as Area2D
	var shapes := Shapes.all_shapes()
	var sizes := Shapes.size_scales()
	var shape_key: String = String(shapes[randi() % shapes.size()])
	var size_scale: float = float(sizes[randi() % sizes.size()])
	add_child(o)
	if o.has_method("configure"):
		o.call("configure", shape_key, size_scale, obstacle_speed)
	var rect := get_viewport_rect()
	var y: float = clamp(randf_range(60.0, float(rect.size.y) - 60.0), 60.0, float(rect.size.y) - 60.0)
	o.position = Vector2(rect.size.x + 100.0, y)
	o.connect("area_entered", Callable(self, "_on_obstacle_area_entered").bind(o))
	o.connect("exited_screen", Callable(self, "_on_obstacle_exit"))

func _on_obstacle_exit() -> void:
	# Missed obstacle: no penalty per design
	pass

func _on_obstacle_area_entered(_area: Area2D, obstacle: Area2D) -> void:
	# Compare shapes and sizes between player and obstacle
	var ok := false
	var p_shape = player.get("current_shape")
	var p_size_index = int(player.get("size_index"))
	var o_shape = obstacle.get("shape_key")
	var o_scale = float(obstacle.get("size_scale"))
	if typeof(p_shape) == TYPE_STRING and typeof(o_shape) == TYPE_STRING:
		ok = (String(p_shape) == String(o_shape))
		if ok and p_size_index >= 0:
			var sizes := Shapes.size_scales()
			if p_size_index < sizes.size():
				ok = is_equal_approx(sizes[p_size_index], o_scale)
	if ok:
		score += 1
		countdown += COUNTDOWN_BONUS
		_update_hud()
		_update_time_label()
		# Visual feedback: green flash for correct hit
		if player and player.has_method("flash_good"):
			player.call("flash_good", 1.0)
		obstacle.queue_free()
	else:
		_lose_life()
		# Visual feedback: red flash for wrong hit
		if player and player.has_method("flash_bad"):
			player.call("flash_bad", 1.0)
		obstacle.queue_free()

func _lose_life() -> void:
	lives -= 1
	_update_hud()
	if lives <= 0:
		_game_over()

func _game_over() -> void:
	get_tree().reload_current_scene()

func _update_hud() -> void:
	hud_score.text = "Score: %d" % score
	hud_lives.text = "Lives: %d" % lives

func _update_time_label() -> void:
	if is_instance_valid(hud_time):
		var shown := int(ceil(max(countdown, 0.0)))
		hud_time.text = "Time: %d" % shown

func _handle_timeout() -> void:
	# Time ran out: lose a life and reset countdown if game continues
	countdown = 0.0
	_update_time_label()
	_lose_life()
	if lives > 0:
		countdown = COUNTDOWN_BONUS
		_update_time_label()
