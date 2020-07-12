extends RichTextLabel

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer");
var activated = false;

func _input(event):
	if (!activated):
		if (Input.is_action_just_pressed("fire")):
			activated=true
			anim_player.play("Fade");
			yield (get_tree().create_timer(2), "timeout");
			queue_free()
