extends Node2D

export var key_power_up = "ui_power_up"
var speed_multiplier

onready var laser_beam := $ArrowBeam
onready var laser_beam_left := $ArrowBeamLeft
onready var laser_beam_right := $ArrowBeamRight

var is_casting := false

func _process(delta):
    if is_casting != Input.is_action_pressed(key_power_up):
        laser_beam.is_casting = !is_casting
        is_casting = !is_casting
    if Input.is_action_pressed(key_power_up):
        if Input.is_action_pressed("paddle_one_down") or Input.is_action_pressed("paddle_two_up"):
            self.rotate(PI* 2 * delta * speed_multiplier)
        if Input.is_action_pressed("paddle_one_up") or Input.is_action_pressed("paddle_two_down"):
            self.rotate(-PI* 2 * delta * speed_multiplier)
