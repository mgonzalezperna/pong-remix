extends RigidBody2D

var rng = RandomNumberGenerator.new()
var screen_size

export(int, 0, 90 ) var rebound_angle_modifier = 10
export(int, 0, 90 ) var angle_clamp = 30
signal on_wall_hit

export var key_power_up = "ui_power_up"

var arrow_rotation

onready var enemies = $".."/Enemies
onready var ripple = $RippleEmitter
onready var paddle = $".."/paddle_player

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size

# Function to manipulate position safetly without corrupting physics engine.
func _integrate_forces(state):
    var ball_state = ball_on_screen(state)
    if paddle.power_up_on:
        ball_state.origin = paddle.global_position
    state.set_transform(ball_state)

func shoot_ball(power):
    power = power if (power > 200) else 200
    self.linear_velocity = Vector2.UP.rotated(arrow_rotation) * power

# If ball left the screen, reapears in the other side.
func ball_on_screen(state):
    var ball_state = state.get_transform()
    if ball_state.origin.x > screen_size.x:
        ball_state.origin.x = 0
    if ball_state.origin.x < 0: 
        ball_state.origin.x = screen_size.x
    return ball_state

func _physics_process(_delta):
    var collition_bodies = get_colliding_bodies()
    for body in collition_bodies:
        if body == paddle and not paddle.power_up_on:
            self.linear_velocity = rebound_vector(body)
            go_to_closest_enemy_in_angle()
        elif body in enemies.get_children():
            enemies.remove_child(body)
    if not collition_bodies.empty() and not paddle.power_up_on:
        clamp_angle()
        hit_effect()

func go_to_closest_enemy_in_angle():
    var closest
    for enemy in enemies.get_children():
        var enemy_direction = enemy.global_position - self.position
        var angle = self.linear_velocity.angle_to(enemy_direction)
        var distance = enemy_direction.length()
        if abs(angle) < PI/4 and (not closest or closest.distance > distance):
            closest = {'distance': distance, 'direction': enemy_direction}
    if closest:
        self.linear_velocity = closest.direction.normalized() * self.linear_velocity.length()
    
# Modifies the ball's linear_velocity angle based on the current movement 
# of the paddle in the instant of collition.  
func rebound_vector(body):
    # If paddle has different direction relative to ball, will decrease the 
    # angle and if the direction is the same, will increase it. To do it, we 
    # must also bear in mind the angle sign relative to scene.
    var sign_rotation = body.get_velocity().normalized().y * self.linear_velocity.sign().x
    var velocity = clamp(self.linear_velocity.length(), 400, 2000)
    return self.linear_velocity.rotated(deg2rad(rebound_angle_modifier) * sign_rotation).normalized() * velocity

func clamp_angle():
    var min_angle = deg2rad(angle_clamp)
    var down_angle = Vector2.DOWN.angle_to(self.linear_velocity)
    var up_angle = Vector2.UP.angle_to(self.linear_velocity)
    
    if abs(up_angle) <= min_angle:
        self.linear_velocity = Vector2.UP.rotated(min_angle * sign(up_angle)) * self.linear_velocity.length()
    elif abs(down_angle) <= min_angle:
        self.linear_velocity = Vector2.DOWN.rotated(min_angle * sign(down_angle)) * self.linear_velocity.length()
        
func hit_effect():
    emit_signal("on_wall_hit")
    ripple.emitting = true
    ripple.restart()

func _on_paddle_player_power_up_activated():
    self.linear_velocity = Vector2(0,0)
    arrow_rotation = paddle.arrow.rotation + paddle.rotation

func _on_paddle_player_power_up_released(shoot_power):
    shoot_ball(shoot_power)
