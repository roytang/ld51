extends KinematicBody2D

signal hit
signal collect_coin
signal update_hud
signal set_camera_limit

export var speed = Vector2(250.0, 300.0)
onready var gravity = 500
onready var sprite = $Sprite
onready var shape = $CollisionShape2D

const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 10.0

var _velocity = Vector2.ZERO
var _stomp_boost = false
var coins = 0
var dead = false
var success = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):

	var direction = get_direction()
	# print(direction)
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = false

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
			
	if _velocity.y != 0:
		$Sprite/AnimatedSprite.animation = "jump"
	elif _velocity.x != 0:
		$Sprite/AnimatedSprite.animation = "w"
	else:
		$Sprite/AnimatedSprite.animation = "default"

	_velocity.y += gravity * delta

		

func get_direction():
	
	if success:
		return Vector2(0, 0) 
		
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
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else ybase
	)

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
	print("Player hit")
	dead = true
	$AnimationPlayer.play("death")
	$CollisionShape2D.disabled = true
	$StompDetector/CollisionShape2D.disabled = true
	$BumpDetector/CollisionShape2D.disabled = true
	self.set_collision_layer_bit(0, false)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death":
		print("Death anim ended")
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
	print("Setting camera limit", margin, position)
	if margin == 0: # MARGIN_LEFT
		$Camera2D.limit_left = position
	if margin == 1: # MARGIN_TOP
		$Camera2D.limit_top = position
	if margin == 2: # MARGIN_RIGHT
		$Camera2D.limit_right = position
	if margin == 3: # MARGIN_BOTTOM
		$Camera2D.limit_bottom = position


func _on_Stage_stage_success():
	success = true
