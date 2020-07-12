extends Timer

func restoreMovementTimer():
	yield (get_tree().create_timer(30), "timeout");
	get_node("../YSort/Player").newMovement()
