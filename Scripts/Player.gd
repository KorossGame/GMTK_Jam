extends KinematicBody2D

#Objects
var bullet = preload("res://Prefabs/Bullet.tscn");

export var push_speed = 50
export var speed = 150;
var direction = Vector2();

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer");

#Movement binds
var actions=["ui_left", "ui_up", "ui_down", "ui_right"];
var events=[KEY_A, KEY_W, KEY_S, KEY_D];
var rng = RandomNumberGenerator.new();

#Fire
export var bullet_speed = 250;
var fire_rate = 0.4;
var can_fire = true;

#Rotation
var characterCam;
var bulletPoint;

#Offset from Player center
var bulletOffset = 40;

func _init():
	restoreMovement();

func _ready():
	characterCam=get_node("Camera2D");
	bulletPoint=get_node("BulletPoint");

func _physics_process(delta):
	var charRotation = characterCam.get_rotation();
	
	#Horizontal
	if Input.is_action_pressed("ui_right"):
		direction.x = 1;
		
		#Animation
		anim_player.play("walk_right");
		
		#Apply Rotation of cam
		characterCam.set_rotation_degrees(0);
		bulletPoint.position = Vector2(bulletOffset, 0);
		
	elif (Input.is_action_pressed("ui_left")):
		direction.x = -1;
		
		#Apply Rotation of cam
		characterCam.set_rotation_degrees(180);
		bulletPoint.position = Vector2(-bulletOffset, 0);
		
		#Animation
		anim_player.play("walk_left");
		
	else: direction.x = 0;
	
	#Vertical
	if (Input.is_action_pressed("ui_down")):
		direction.y = 1;
		
		#Apply Rotation of cam
		characterCam.set_rotation_degrees(90);
		bulletPoint.position = Vector2(0, bulletOffset);
		
		#Animation
		anim_player.play("walk_down")
		
	elif (Input.is_action_pressed("ui_up")):
		direction.y = -1;
		
		#Apply Rotation of cam
		characterCam.set_rotation_degrees(-90);
		bulletPoint.position = Vector2(0, -bulletOffset);
		
		#Animation
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
		
func restoreMovement():
	resetActions();
	#Aplly normal movement
	for i in len(events):
		var newEvent = InputEventKey.new()
		newEvent.scancode = events[i]
		InputMap.action_add_event(actions[i], newEvent);
		
func newMovement():
	
	var usedActions=[];
	resetActions();
	 
	for event in events:
		var newEvent = InputEventKey.new()
		newEvent.scancode = event
		var allSet = false;
		
		while (!allSet):
			randomize();
			var my_random_number = rng.randi_range(0,3);
			
			if usedActions.has(my_random_number):
				pass
			else:
				usedActions.append(my_random_number);
				allSet=!allSet;
				InputMap.action_add_event(actions[my_random_number], newEvent);

func resetActions():
	#Delete movement binds if such exists
	for action in actions:
		InputMap.erase_action(action);
	#Add new binds
	for action in actions:
		InputMap.add_action(action);
		
func _process(delta):
	
	#Check if player hits fire button
	if (Input.is_action_pressed("fire") && can_fire):
		#Create instance
		var bulletInstance = bullet.instance();
		bulletInstance.position = $BulletPoint.get_global_position();
		bulletInstance.rotation_degrees = characterCam.rotation_degrees;
		bulletInstance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(characterCam.get_rotation()));
		get_tree().get_root().add_child(bulletInstance);
		can_fire = !can_fire;
		yield (get_tree().create_timer(fire_rate), "timeout");
		can_fire = !can_fire;

func check_box_collision(motion: Vector2) -> void:
	if abs(motion.x) + abs(motion.y) > 1:
		return
	var box : = get_slide_collision(0).collider as box
	if box: 
		box.push(push_speed * motion)

