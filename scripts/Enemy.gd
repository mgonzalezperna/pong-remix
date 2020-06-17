extends Area2D

func _on_Enemy_body_entered(ball):
    ball.hit_effect()
    ball.linear_velocity = ball.linear_velocity * 0.8
    queue_free()
