extends RichTextLabel

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer");

var triggers=[]

func process(delta):
	if (len(triggers)==4):
		anim_player.play("Fade");
		yield (get_tree().create_timer(1), "timeout");
		queue_free()


func _on_Shawarma24_body_entered(body):
	triggers.append(1)

func _on_Shawarma25_body_entered(body):
	triggers.append(1)
	
func _on_Shawarma26_body_entered(body):
	triggers.append(1)
	
func _on_Shawarma27_body_entered(body):
	triggers.append(1)
