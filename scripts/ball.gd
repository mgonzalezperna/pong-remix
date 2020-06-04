extends RigidBody2D

var screen_size
export(float, 0, 1) var paddle_angle_override = 0.5
export(int, 0, 180) var max_rotation_override = 45
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Function to manipulate position safetly without corrupting physics engine.
func _integrate_forces(state):
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


func _process(delta):
	var collition_bodies = get_colliding_bodies()
	for body in collition_bodies:
		if body.get_name() in ["paddle_player1", "paddle_player2"]:
			# var shape = get_node(NodePath("../" + body.get_name() + "/CollisionShape2D")).get_shape()
			var paddleOffset = body.get_name() == "paddle_player1" if -40 else 40
			var hit_vector = (body.position + Vector2(paddleOffset, 0)).direction_to(self.position)
			var rotation = self.linear_velocity.angle_to(hit_vector) * paddle_angle_override
			print('rotation ', rad2deg(rotation))
			rotation = clamp(rotation, -deg2rad(max_rotation_override), deg2rad(max_rotation_override))
			self.linear_velocity = self.linear_velocity.rotated(rotation)
