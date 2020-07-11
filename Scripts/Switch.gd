extends Area2D

func _on_Switch_body_entered(body: Node) -> void:
	get_node("../YSort/Player").restoreMovement();
	get_node("../Timer").restoreMovementTimer();

