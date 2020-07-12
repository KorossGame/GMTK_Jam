extends Area2D

onready var anim_player = get_node("AnimationPlayer");
onready var player = get_node("../YSort/Player");

var rng = RandomNumberGenerator.new();

func _ready():
	rng.randomize();

func _on_body_entered(body):
	anim_player.play("Fade");
	player.activatePowerUP(rng.randi_range(0,3));

