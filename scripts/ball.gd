extends RigidBody2D

var screen_size

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
			var hit_vector = body.position.direction_to(self.position)
			var rotation = self.linear_velocity.angle_to(hit_vector) / 2
			print('hit_angle ', hit_vector.angle())
			print('linear_velocity ', self.linear_velocity.angle())
			print('rotation ', rotation)
			self.linear_velocity = self.linear_velocity.rotated(rotation)
