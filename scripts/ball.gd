extends RigidBody2D

var screen_size

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

func _physics_process(delta):
    var collition_bodies = get_colliding_bodies()
    for body in collition_bodies:
        if body.get_name() in ["paddle_player1", "paddle_player2"]:
            if body.position.x != self.position.x:
                var impulse_x = body.get_velocity().x
                var impulse_y = body.get_velocity().y
                self.apply_central_impulse(Vector2(body.get_velocity()))

#    var collision = move_and_collide(velocity * delta)
#    if collision:
#        velocity = velocity.bounce(collision.normal)
#        if collision.collider.has_method("hit"):
#            collision.collider.hit()
