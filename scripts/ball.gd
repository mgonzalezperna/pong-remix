extends RigidBody2D

var rng = RandomNumberGenerator.new()
var screen_size
export(float) var rebound_angle_modifier = 10
export var key_power_up = "ui_power_up"
onready var enemies = $".."/Enemies
# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size

# Function to manipulate position safetly without corrupting physics engine.
func _integrate_forces(state):
    state.set_angular_velocity(0)
    var ball_state = ball_state_on_screen(state)
    state.set_transform(ball_state)

# If ball left the screen, reapears in the other side.
func ball_state_on_screen(state):
    var ball_state = state.get_transform()
    if ball_state.origin.x > screen_size.x:
        ball_state.origin.x = 0
    if ball_state.origin.x < 0: 
        ball_state.origin.x = screen_size.x
    return ball_state

func _physics_process(_delta):
    var paddle = $".."/paddle_player
    var ball_in_power_up_zone = paddle.power_up_area.overlaps_body(self)
    if ball_in_power_up_zone and Input.is_action_pressed(key_power_up):
        var arrow_rotation = paddle.arrow.rotation + paddle.rotation
        # The function y = 1/(1.1) ^ (x - 55) describes the relation that
        # transforms the shooting speed.
        var velocity_multiplier = pow(1/1.1, int(
            self.global_position.distance_to(paddle.global_position)-55))
        var shoot_velocity = paddle.speed + 10 * velocity_multiplier
        self.linear_velocity = Vector2.UP.rotated(arrow_rotation) * shoot_velocity
    else:
        var collition_bodies = get_colliding_bodies()
        for body in collition_bodies:
            if body == paddle:
                self.linear_velocity = rebound_vector(body)
            elif body in enemies.get_children():
            enemies.remove_child(body)
            goToClosestEnemyInAngle()

func goToClosestEnemyInAngle():
    var closest
    for enemy in enemies.get_children():
        var enemy_direction = enemy.global_position - self.position
        var angle = self.linear_velocity.angle_to(enemy_direction)
        var distance = enemy_direction.length()
        if abs(angle) < PI/4 and (not closest or closest.distance > distance):
            closest = {'distance': distance, 'direction': enemy_direction}
    if closest:
        self.linear_velocity = closest.direction.normalized() * 200
    
# Modifies the ball's linear_velocity angle based on the current movement 
# of the paddle in the instant of collition.  
func rebound_vector(body):
    var rebound_angle = ball_angle_on_scene(
        body, atan(self.linear_velocity.y / self.linear_velocity.x))
    # If paddle has different direction relative to ball, will decrease the 
    # angle and if the direction is the same, will increase it. To do it, we 
    # must also bear in mind the angle sign relative to scene.
    match(body.get_velocity().normalized().y * self.linear_velocity.sign().y):
        -1.0:
            rebound_angle -= angle_sign(rebound_angle) * deg2rad(rebound_angle_modifier)
        1.0:
            rebound_angle += angle_sign(rebound_angle) * deg2rad(rebound_angle_modifier)
        _:
            pass
    return impulse_vector(self.linear_velocity.length(), rebound_angle)

func angle_sign(angle):
    var angle_sign = 1
    if round(angle) != 0:
        angle_sign = round(angle)/abs(round(angle))
    return angle_sign

# Converts angle value from relative to ball to relative to scene.
func ball_angle_on_scene(body, angle):
    var angle_on_scene = angle
    if body.position.x > self.position.x:
        angle_on_scene += deg2rad(180)
    return angle_on_scene

# This function is used to modify the resulting collition vector with a 
func impulse_vector(length, angle):    
    var impulse_vector = polar2cartesian(length, angle)
    return impulse_vector
