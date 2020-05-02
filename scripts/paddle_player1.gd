extends KinematicBody2D

export var speed = 400  # How fast the player will move (pixels/sec).
export var key_up = "ui_up"
export var key_down = "ui_down"
export var key_slowmo = "ui_slowmo"
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
     screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var timescale = process_slowmo() 
    Engine.time_scale = timescale 
    position += proc_movement(delta, timescale)
    position.y = clamp_y_movement(position)

func process_slowmo():
    var timescale = 1
    if Input.is_action_pressed(key_slowmo):
        timescale = 0.3
    return timescale

func proc_movement(delta, timescale):
    var velocity = Vector2()  # The player's movement vector.
    var paddle_speed = speed / timescale
    if Input.is_action_pressed(key_down):
        velocity.y += 1
    if Input.is_action_pressed(key_up):
        velocity.y -= 1
    if velocity.length() > 0:
        velocity = velocity.normalized() * paddle_speed
    return velocity * delta

func clamp_y_movement(position):
    var paddle_margin = $CollisionShape2D.shape.get_extents().x/2
    return clamp(position.y, paddle_margin, screen_size.y-paddle_margin)
