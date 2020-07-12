extends KinematicBody2D

#Health
var maxHP = 100;
onready var invulnerabilityTimer = get_node("../../InvulnerabilityTimer");
onready var RespawnPoint = get_node("../../RespawnPoint");
onready var HealthBar = get_node("../../CanvasLayer/HealthBar/ProgressBar");
onready var HP = maxHP setget _setHP;

func kill():
	anim_player.play("Death")
	set_physics_process(false);
	set_process(false);
	yield (get_tree().create_timer(2), "timeout");
	respawn();
	
func damage(amount):
	if (invulnerabilityTimer.is_stopped()):
		invulnerabilityTimer.start();
		_setHP(HP-amount);

func _setHP(value):
	var prevHP=HP;
	HP = clamp(value, 0 , maxHP);
	HealthBar.value=HP;
	if (HP==0):
		kill()
	
func respawn():
	position=RespawnPoint.position;
	set_physics_process(true);
	set_process(true);
	anim_player.play("idle_right")
	_setHP(maxHP);
	
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
export var fire_rate = 0.4;
var can_fire = true;

#Rotation
var characterCam;
var bulletPoint;

#Offset from Player center
var bulletOffset = 40;

#PowerUP time
var timer;
var timer1;
var powerUPTime=20;

func _init():
	restoreMovement();

func _ready():
	characterCam=get_node("Camera2D");
	bulletPoint=get_node("BulletPoint");
	damage(0);
	anim_player.play("idle_right");
	rng.randomize();
	#Timer for 1st powerUP
	timer = Timer.new();
	timer.set_one_shot(true);
	timer.set_wait_time(powerUPTime);
	timer.connect("timeout", self, "fire_rate_timer_done");
	add_child(timer);
	#Timer for 2nd powerUP
	timer1 = Timer.new();
	timer1.set_one_shot(true);
	timer1.set_wait_time(powerUPTime);
	timer1.connect("timeout", self, "speed_timer_done");
	add_child(timer1);
	
func fire_rate_timer_done():
	fire_rate=0.4;
	get_node("../../CanvasLayer/FireRate").popup_hide()

func speed_timer_done():
	speed=150;
	get_node("../../CanvasLayer/Speed").popup_hide()

func activatePowerUP(powerUP):
	if (powerUP==0):
		fire_rate=0.2;
		get_node("../../CanvasLayer/FireRate").show()
		timer.start()
	elif (powerUP==1):
		speed=500;
		timer1.start();
	elif (powerUP==2):
		restoreMovement();
		get_node("../../CanvasLayer/NormalMovement").popup_show()
	elif (powerUP==3):
		_setHP(100)
		get_node("../../CanvasLayer/Heal").popup_show()
		
func _physics_process(delta):
	
	if timer.time_left > 0:
		get_node("../../CanvasLayer/FireRateLabel").set_time() 
		get_node("../../CanvasLayer/FireRate").show()
	else:
		get_node("../../CanvasLayer/FireRateLabel").timeclear() 
		get_node("../../CanvasLayer/FireRate").hide()
	
	if timer1.time_left > 0:
		get_node("../../CanvasLayer/SpeedTimeLabel").set_time() 
		get_node("../../CanvasLayer/Speed").show()
	else:
		get_node("../../CanvasLayer/SpeedTimeLabel").timeclear()
		get_node("../../CanvasLayer/Speed").hide()
	
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
		anim_player.play("idle_up")
	
	#Move
	move_and_slide(direction.normalized() * speed);
	
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
		
func getTimeLeft(): 
	 return timer.get_time_left()

func getTimeLeft1(): 
	 return timer1.get_time_left()
	
func _process(delta):
	#Timers
	timer.get_time_left();
	timer1.get_time_left();
	
	if (Input.is_action_pressed("ui_select")):
		damage(10);

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

func check_box_collision(motion):
	if abs(motion.x) + abs(motion.y) > 1:
		return
	var box : = get_slide_collision(0).collider as box
	if box: 
		box.push(push_speed * motion)

