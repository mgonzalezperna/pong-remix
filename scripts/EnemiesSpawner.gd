tool
extends Node2D

export var EnemyScene: PackedScene
export var count_min := 1
export var count_max := 5
export var spawn_radius := 150.0

onready var timer = $'..'/Timer
onready var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    timer.connect("timeout", self, "spawn_enemies")
    timer.start()

func spawn_enemies() -> void:
    var enemies := get_children()
    for _i in range(rng.randi_range(count_min, count_max) - enemies.size()):
        var enemy := EnemyScene.instance()
        enemy.position = Vector2.UP.rotated(rng.randf_range(0, PI * 2)) * rng.randf_range(0, spawn_radius)
        add_child(enemy)

func _draw():
    if not Engine.editor_hint:
        return
    var points_array = PoolVector2Array()
    for i in range(128):
        var new_point = Vector2.UP.rotated(PI * i / 64) * spawn_radius
        points_array.append(new_point)
    draw_polyline(points_array, Color(1.0,1.0,1.0, 0.2), 1.0, true)

