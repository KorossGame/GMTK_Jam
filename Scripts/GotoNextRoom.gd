extends Area2D

func _on_NextRoom_body_entered(body):
	get_node("../Player").newMovement();
