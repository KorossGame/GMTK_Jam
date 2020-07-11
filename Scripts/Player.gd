extends KinematicBody2D

#Objects
var bullet = preload("res://Prefabs/Bullet.tscn");

export var speed = 150;
var direction = Vector2();

#Movement function (called every physics frame)
func _physics_process(delta):

	#Horizontal
	if Input.is_action_pressed("ui_right"):
		direction.x = 1;
	elif (Input.is_action_pressed("ui_left")):
		direction.x = -1;
	else: direction.x = 0;
	
	#Vertical
	if (Input.is_action_pressed("ui_down")):
		direction.y = 1;
	elif (Input.is_action_pressed("ui_up")):
		direction.y = -1;
	else: direction.y = 0;
	
	#Move
	move_and_slide(direction * speed);

export var bullet_speed = 250;
var fire_rate = 0.2;
var can_fire = true;

func _process(delta):
	#Looking at mouse possition (called every frame)	
	look_at(get_global_mouse_position());
	
	#Check if player hits fire button
	if (Input.is_action_pressed("fire") && can_fire):
		#Create instance
		var bulletInstance = bullet.instance();
		bulletInstance.position = $BulletPoint.get_global_position();
		bulletInstance.rotation_degrees = rotation_degrees;
		bulletInstance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation));
		get_tree().get_root().add_child(bulletInstance);
		can_fire = !can_fire;
		yield (get_tree().create_timer(fire_rate), "timeout");
		can_fire = !can_fire;
