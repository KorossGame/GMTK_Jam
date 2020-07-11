extends Area2D

export (String, FILE) var worldScene;

func _on_NextScene_body_entered(body):
	get_tree().change_scene(worldScene);
