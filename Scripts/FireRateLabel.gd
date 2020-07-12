extends RichTextLabel

func set_time():
	var time = get_node("../../YSort/Player").getTimeLeft()
	time = stepify(time, 0.01)
	set_text(String(time))

func timeclear():
	set_text("")
