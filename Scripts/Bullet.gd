extends RigidBody2D

var rng = RandomNumberGenerator.new();

func _ready():
	rng.randomize();
	
func _on_Bullet_body_entered(body):
	if (body.is_in_group("player") || body.is_in_group("enemy")):
		body.damage(rng.randi_range(20,50));
		queue_free();
	else:
		queue_free();
