extends KinematicBody2D

export var speed = 400  # How fast the player will move (pixels/sec).
export var power_up_limit = 1000.00
export var power_up_total = 1000.00 # The amount of power up.
export var power_up_consumption = 10 #The consumption per cycle of usage of power up.
export var power_up_shoot_increase = 10 #The raise on the power of shoot in each cycle of power up.

#Inputs
var paddle_up = "paddle_up"
var paddle_down = "paddle_down"
var paddle_left = "paddle_left"
var paddle_right = "paddle_right"
export var key_slowmo = "ui_slowmo"
export var key_power_up = "ui_power_up"

#Other vars
var screen_size
var velocity
var power_up_available = false
var power_up_on = false
var shoot_power = 0
signal power_up_activated()
signal power_up_released(power)
signal on_power_up_charging(power_up_load)

onready var arrow = $arrow

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    arrow.show()
    
func get_velocity():
    return velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    var timescale = process_slowmo()
    power_up_on = get_power_up_status()
    Engine.time_scale = timescale.engine

    if not power_up_on:
        if Input.is_action_pressed(paddle_left):
            position.x = 88
            rotation = PI / 2
            $arrow.inverted = false
        elif Input.is_action_pressed(paddle_right):
            position.x = 936
            rotation = - PI / 2
            $arrow.inverted = true
    else:
        power_up_total -= power_up_consumption
        shoot_power += power_up_shoot_increase
        process_power_up_visuals()
    velocity = get_movement_velocity(timescale.paddle)
    $arrow.speed_multiplier = timescale.arrow
    position += velocity * delta
    position.y = clamp_axis_movement(position)

func process_power_up_visuals():
    var power_up_load = (power_up_limit-power_up_total)/power_up_limit
    $arrow.laser_beam.scale.x = power_up_load
    $Sprite/PowerUpInterface.scale.x = 1 - power_up_load
    emit_signal("on_power_up_charging", power_up_load)

func get_power_up_status():    
    var status = false
    if power_up_available:
        if Input.is_action_pressed(key_power_up) and power_up_total > 0:
            if !power_up_on:
                emit_signal("power_up_activated")
            status = true
        else:
            if power_up_on:
                emit_signal("power_up_released", shoot_power)
    return status    

func process_slowmo():
    if Input.is_action_pressed(key_slowmo):
         return {"engine": 0.3, "paddle": 2, "arrow": 2}

    return {"engine": 1, "paddle": 1, "arrow": 1}

func get_movement_velocity(timescale):
    var velocity = Vector2()  # The player's movement vector.
    var paddle_speed = speed * timescale
    if Input.is_action_pressed(key_power_up):
        return velocity
    if Input.is_action_pressed(paddle_down):
        velocity.y += 1
    if Input.is_action_pressed(paddle_up):
        velocity.y -= 1
    if velocity.length() > 0:
        velocity = velocity.normalized() * paddle_speed
    return velocity

func clamp_axis_movement(position):
    var paddle_margin = $CollisionShape2D.shape.get_extents().x/2
    return clamp(position.y, paddle_margin, screen_size.y-paddle_margin)

func _on_power_up_area_body_entered(body):
    power_up_available = $power_up_area.overlaps_body(body) and body.name == "ball"

func _on_power_up_area_body_exited(body):
    power_up_available = false
    if power_up_total < 1000:
        power_up_total += 1000
        $Sprite/PowerUpInterface.scale.x = 1
    shoot_power = 0
    
