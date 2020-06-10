extends Node2D

export var key_power_up = "ui_power_up"

onready var laser_beam := $ArrowBeam
onready var laser_beam_left := $ArrowBeamLeft
onready var laser_beam_right := $ArrowBeamRight

var is_casting := false
var inverted := false setget set_inverted
var speed_multiplier := 1.0
var arrow_down = "paddle_down"
var arrow_up = "paddle_up"

func set_inverted(_inverted):
    if inverted != _inverted:
        inverted = _inverted
        rotation *= -1

func _process(delta):
    if is_casting != Input.is_action_pressed(key_power_up):
        laser_beam.is_casting = !is_casting
        is_casting = !is_casting
    if Input.is_action_pressed(key_power_up):
        if Input.is_action_pressed(arrow_down):
            rotate(PI * 2 * delta * speed_multiplier * (-1 if inverted else 1))
        if Input.is_action_pressed(arrow_up):
            rotate(-PI * 2 * delta * speed_multiplier * (-1 if inverted else 1) )
