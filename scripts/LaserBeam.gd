extends Node2D

export var cast_speed := 1.0
export var max_length := 300
export var growth_time := 0.1
export var inverted := false
export var delay := 0.0

onready var casting_particles := $CastingParticles2D
onready var beam_particles := $BeamParticles2D
onready var collision_particles := $CollisionParticles2D
onready var fill := $FillLine2D
onready var tween := $Tween
onready var line_width: float = fill.width

var is_casting := false setget set_is_casting
var cast_to := Vector2.ZERO

func _ready() -> void:
    set_physics_process(false)
    fill.points[1] = Vector2.ZERO
    beam_particles.emitting = false
    collision_particles.emitting = false
    casting_particles.emitting = false   
    if inverted:
        collision_particles.position = Vector2.RIGHT * max_length
        collision_particles.rotation = PI
    casting_particles.position = Vector2.RIGHT * max_length
    casting_particles.rotation = PI

func _physics_process(delta: float) -> void:
    fill.points[1] = cast_to
    beam_particles.position = cast_to * 0.5
    beam_particles.process_material.emission_box_extents.x = cast_to.length()
    if inverted:
        casting_particles.emitting = cast_to.length() > max_length * 0.9
        beam_particles.emitting = cast_to.length() > 0
    else:
        casting_particles.emitting = cast_to.length() > max_length * 0.9

func set_is_casting(cast: bool) -> void:
    is_casting = cast
    if is_casting:
        cast_to = Vector2.ZERO
        _physics_process(0)
        appear()
    else:
        disappear()

    set_physics_process(is_casting)
    if !inverted:
        beam_particles.emitting = is_casting
        collision_particles.emitting = is_casting

func appear() -> void:
    if inverted:
        beam_particles.emitting = false
        collision_particles.emitting = false
    casting_particles.emitting = false    
    
    if tween.is_active():
        tween.stop_all()
    tween.interpolate_property(fill, "width", 0, line_width, growth_time * 2, tween.TRANS_LINEAR, tween.EASE_IN_OUT, delay)
    tween.interpolate_property(self, "cast_to", Vector2.ZERO, Vector2.RIGHT * max_length, cast_speed, tween.TRANS_LINEAR, tween.EASE_IN_OUT, delay)
    tween.start()


func disappear() -> void:
    beam_particles.emitting = false
    collision_particles.emitting = false
    casting_particles.emitting = false  
    if tween.is_active():
        tween.stop_all()
    tween.interpolate_property(fill, "width", null, 0, growth_time)
    tween.interpolate_property(self, "cast_to", null, Vector2.ZERO, cast_speed, tween.TRANS_LINEAR, tween.EASE_IN_OUT)
    tween.start()
