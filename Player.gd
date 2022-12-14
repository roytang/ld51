extends KinematicBody2D

signal hit
signal collect_coin
signal update_hud
signal set_camera_limit
signal start_dash

export var speed = Vector2(250.0, 300.0)
onready var gravity = 500
onready var sprite = $Sprite
onready var shape = $CollisionShape2D
onready var leftwallcheck = $LeftWallRaycasts
onready var rightwallcheck = $RightWallRaycasts

const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 10.0

var _velocity = Vector2.ZERO
var _stomp_boost = false
var coins = 0
var dead = false
var success = false

var dashing = false
var dash_direction = Vector2(0, 0)
var dash_speed = 1000.0
var dash_start = 0
var dash_duration = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if dashing:
		var time_now = Time.get_unix_time_from_system()
		# compute remaining time
		var unix_time: float = dash_duration - (time_now - dash_start)
		if unix_time < 0:
			dashing = false

func _physics_process(delta):

	var direction = get_direction()
	# print(direction)
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	
	if _can_jump(direction.x) and Input.is_action_just_pressed("jump"):
		$JumpSound.play()
	
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = false
	
	if dashing:
		# jumping cancels the dash
		if Input.is_action_just_pressed("jump"):
			dashing = false
		else:
			# dashing ignores all of the above!
			direction = dash_direction
			_velocity = direction * dash_speed

	if dead or success:
		# we still let the player drop to the ground on death or success
		_velocity.x = 0.0
		
		
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false
	)
		
	# When the character’s direction changes, we want to to scale the Sprite accordingly to flip it.
	if direction.x != 0:
		if direction.x > 0:
			sprite.scale.x = 1
			shape.scale.x = 1
		else:
			sprite.scale.x = -1
			shape.scale.x = -1
			
	if dead:
		$Sprite/AnimatedSprite.animation = "dead"
	elif _velocity.y != 0:
		$Sprite/AnimatedSprite.animation = "jump"
	elif _velocity.x != 0:
		$Sprite/AnimatedSprite.animation = "walk"
	else:
		$Sprite/AnimatedSprite.animation = "default"

	_velocity.y += gravity * delta

		

func get_direction():
	
	if success:
		return Vector2(0, 0) 
	if dead:
		return Vector2(0, 1) # fall to the ground if you can
		
	var ybase = 0
	if _stomp_boost:
		_stomp_boost = false
		ybase = -1
		
	var hdir = 0.0
	if Input.is_action_pressed("ui_right"):
		hdir = hdir + 1.0
	if Input.is_action_pressed("ui_left"):
		hdir = hdir - 1.0
	return Vector2(
		hdir,
		-1 if _can_jump(hdir) and Input.is_action_just_pressed("jump") else ybase
	)

func _can_jump(hdir):
	if is_on_floor():
		return true
	# can always jump when dashing
	if dashing:
		return true
	var close = _is_close_to_wall(rightwallcheck)
	# print("close ", close, hdir)
	if _is_close_to_wall(rightwallcheck) and hdir > 0:
		return true
	if _is_close_to_wall(leftwallcheck) and hdir < 0:
		return true
		

func _is_close_to_wall(raycasts):
	# all the raycasts in the set must return true
	for r in raycasts.get_children():
		if not r.is_colliding():
			return false
	return true
	
# This function calculates a new velocity whenever you need it.
# It allows you to interrupt jumps.
func calculate_move_velocity(
		linear_velocity,
		direction,
		speed,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
	return velocity


func _on_Player_hit():
	# print("Player hit")
	if dead:
		return
	dead = true
	$AnimationPlayer.play("death")
	$CollisionShape2D.disabled = true
	$StompDetector/CollisionShape2D.disabled = true
	# $BumpDetector/CollisionShape2D.disabled = true
	self.set_collision_layer_bit(0, false)
	$HitSound.play()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death":
		# print("Death anim ended")
		$Sprite.queue_free()


func _on_StompDetector_body_entered(body):
	if body.is_in_group("stompables") and not dead:
		body.emit_signal("stomp")
		_stomp_boost = true


func _on_BumpDetector_body_entered(body):
	if body.is_in_group("bumpables") and not dead:
		body.emit_signal("bump")


func _on_Player_collect_coin():
	coins = coins + 1
	emit_signal("update_hud", self)



func _on_Customer_delivered():
	$Sprite/PizzaAnimatedSprite2.animation = "delivered"


func _on_Player_set_camera_limit(margin, position):
	# print("Setting camera limit", margin, position)
	if margin == 0: # MARGIN_LEFT
		$Camera2D.limit_left = position
	if margin == 1: # MARGIN_TOP
		$Camera2D.limit_top = position
	if margin == 2: # MARGIN_RIGHT
		$Camera2D.limit_right = position
	if margin == 3: # MARGIN_BOTTOM
		$Camera2D.limit_bottom = position


func _on_Stage_stage_success(bonus):
	success = true


func _on_Player_start_dash(dashdir:Vector2):
	dashing = true
	dash_direction = dashdir
	dash_start = Time.get_unix_time_from_system()
