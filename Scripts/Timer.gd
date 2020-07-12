extends Timer

func restoreMovementTimer():
	get_node("../CanvasLayer/NormalMovement").show()
	yield (get_tree().create_timer(30), "timeout");
	get_node("../CanvasLayer/NormalMovement").popup_hide()
	get_node("../YSort/Player").newMovement()
