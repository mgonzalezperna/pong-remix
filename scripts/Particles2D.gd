extends Particles2D

func _process(delta):
    var direction = get_parent().linear_velocity;
    self.process_material.set_direction(Vector3(-direction.x, -direction.y, 0))
