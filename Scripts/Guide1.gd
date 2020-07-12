extends RichTextLabel

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer");

func _input(event):
	if (Input.is_action_just_released("fire")):
		anim_player.play("Fade");
		yield (get_tree().create_timer(2), "timeout");
		queue_free()
