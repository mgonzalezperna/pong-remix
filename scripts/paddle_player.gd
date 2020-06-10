extends KinematicBody2D

export var speed = 400  # How fast the player will move (pixels/sec).
var paddle_up = "paddle_up"
var paddle_down = "paddle_down"
var paddle_left = "paddle_left"
var paddle_right = "paddle_right"
export var key_slowmo = "ui_slowmo"
export var key_power_up = "ui_power_up"
var screen_size
var velocity

onready var arrow = $arrow

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    arrow.show()
    
func get_velocity():
    return velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var timescale = process_slowmo()
    Engine.time_scale = timescale.engine
    
    if !Input.is_action_pressed(key_power_up):
        if Input.is_action_pressed(paddle_left):
            position.x = 88
            rotation = PI / 2
            $arrow.inverted = false
        elif Input.is_action_pressed(paddle_right):
            position.x = 936
            rotation = - PI / 2
            $arrow.inverted = true
    
    velocity = get_movement_velocity(timescale.paddle)
    $arrow.speed_multiplier = timescale.arrow

    position += velocity * delta
    position.y = clamp_axis_movement(position)

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
