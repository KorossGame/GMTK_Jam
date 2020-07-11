extends KinematicBody2D

#Objects
var bullet = preload("res://Prefabs/Bullet.tscn");

export var speed = 150;
var direction = Vector2();

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

#Movement function (called every physics frame)
func _physics_process(delta):

	#Horizontal
	if Input.is_action_pressed("ui_right"):
		direction.x = 1;
		anim_player.play("walk_right")
	elif (Input.is_action_pressed("ui_left")):
		direction.x = -1;
		anim_player.play("walk_left")
	else: direction.x = 0;
	
	#Vertical
	if (Input.is_action_pressed("ui_down")):
		direction.y = 1;
		anim_player.play("walk_down")
	elif (Input.is_action_pressed("ui_up")):
		direction.y = -1;
		anim_player.play("walk_up")
	else: direction.y = 0;
	
	
	
	#Idle Animations
	if (Input.is_action_just_released("ui_right")):
		anim_player.play("idle_right")
	elif (Input.is_action_just_released("ui_left")):
		anim_player.play("idle_left")
	elif (Input.is_action_just_released("ui_down")):
		anim_player.play("idle_down")
	elif (Input.is_action_just_released("idle_up")):
		anim_player.play("idle_down")
	
	#Move
	move_and_slide(direction * speed);
	
	if get_slide_count() > 0:
		check_box_collision(direction)

export var bullet_speed = 250;
var fire_rate = 0.2;
var can_fire = true;

func _process(delta):
	
	
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

export var push_speed = 50
func check_box_collision(motion: Vector2) -> void:
	if abs(motion.x) + abs(motion.y) > 1:
		return
	var box : = get_slide_collision(0).collider as box
	if box: 
		box.push(push_speed * motion)


