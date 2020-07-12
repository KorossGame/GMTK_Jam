extends Popup

func popup_hide():
	visible = false

func popup_show():
	show()
	yield (get_tree().create_timer(5), "timeout")
	visible = false
