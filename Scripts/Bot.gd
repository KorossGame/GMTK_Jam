extends KinematicBody2D

var bullet = preload("res://Prefabs/Bullet.tscn");

onready var player = get_parent().get_node("YSort/Player");
onready var HealthBar = get_node("EnemyHealthBar/ProgressBar");

var speed = 75;
var direction = Vector2();
var playerOffset = 40;
var bulletOffset = 40;
var can_fire = true;
var fire_rate = 0.5;
var bulletSpeed=350;
var bulletPoint;

var HP;
var maxHP=100;

func damage(amount):
	_setHP(HP-amount);
	
func _setHP(newHP):
	HP=newHP;
	HealthBar.value=HP;
	if (HP<=0):
		kill();

func kill():
	queue_free()

func _ready():
	set_process(true);
	bulletPoint=get_node("BulletPoint");
	_setHP(maxHP);
	HealthBar.set_max(maxHP);

func _process(delta):
	if (seePlayer()):
		var angle=get_angle_to(player.position)
		
		#Movement
		if (player.position.x < position.x - playerOffset):
			direction.x = -1;
			bulletPoint.position = Vector2(cos(angle)-bulletOffset, sin(angle));
			
		elif (player.position.x > position.x + playerOffset):
			direction.x = 1;
			bulletPoint.position = Vector2(cos(angle)+bulletOffset, sin(angle));
		else:
			direction.x = 0;
			
		if (player.position.y < position.y - playerOffset):
			direction.y = -1;
			bulletPoint.position = Vector2(cos(angle), sin(angle)-bulletOffset);
			
		elif (player.position.y > position.y  + playerOffset):
			direction.y = 1;
			bulletPoint.position = Vector2(cos(angle), sin(angle)+bulletOffset);
		else:
			direction.y = 0;
		
		move_and_slide(direction*speed);
		
		#Fire at player
		if (can_fire):
			var bulletInstance = bullet.instance();
			bulletInstance.position = $BulletPoint.get_global_position();
			bulletInstance.apply_impulse(Vector2(), Vector2(bulletSpeed, 0).rotated(angle));
			get_tree().get_root().add_child(bulletInstance);
			can_fire = !can_fire;
			yield (get_tree().create_timer(fire_rate), "timeout");
			can_fire = !can_fire;

var eyeOffset = 10;
var vision = 600;

func seePlayer():
	var centerEye = get_global_position();
	var leftEye = centerEye + Vector2(-eyeOffset, 0);
	var rightEye = centerEye + Vector2(eyeOffset, 0);
	var topEye = centerEye + Vector2(0, -eyeOffset);
	var bottomEye = centerEye + Vector2(0, eyeOffset);
	
	#Get player pos
	var playerPos= player.get_global_position();
	var playerExtents = player.get_node("CollisionShape2D").shape.extents - Vector2(1,1)
	
	var topLeft = playerPos+Vector2(-playerExtents.x, -playerExtents.y);
	var topRight = playerPos+Vector2(playerExtents.x, -playerExtents.y);
	var bottomLeft = playerPos+Vector2(-playerExtents.x, playerExtents.y);
	var bottomRight = playerPos+Vector2(playerExtents.x, playerExtents.y);
	
	var spaceState = get_world_2d().direct_space_state
	
	for eye in [centerEye, leftEye, rightEye, topEye, bottomEye]:
		for corner in [topLeft, topRight, bottomLeft, bottomRight]:
			if (corner-eye).length()>vision:
				continue
			var collision = spaceState.intersect_ray(eye, corner, [self], 9);
			if collision and collision.collider.name=="Player":
				return true;
	return false;
				
