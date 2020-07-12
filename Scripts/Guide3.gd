extends RichTextLabel

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer");

func _on_RestoreSwitch_body_entered(body):
	anim_player.play("Fade");
	yield (get_tree().create_timer(2), "timeout");
	queue_free()
