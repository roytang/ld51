extends KinematicBody2D

signal stomp

export var speed = Vector2(120.0, 350.0)
export var initial_facing = -1
var _velocity = Vector2.ZERO
onready var gravity = 1000
const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0
onready var sprite = $AnimatedSprite
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_velocity.x = speed.x * initial_facing
	


func _physics_process(delta):

	
	var direction = Vector2(1, 0)
	if _velocity.x < 0:
		direction = Vector2(-1, 0)
	_velocity = calculate_move_velocity(_velocity, direction, speed)

	if is_on_wall():
		_velocity.x *= -1
	elif is_on_floor():
		# print("is on floor")
		# print(_velocity.x)
		# print("left is colliding:", $FloorDetectorLeft.is_colliding())
		# print("right is colliding:", $FloorDetectorRight.is_colliding())
		# if _velocity.x > 0 and not $FloorDetectorLeft.is_colliding():
			#_velocity.x *= -1
		#elif _velocity.x < 0 and not $FloorDetectorRight.is_colliding():
			# _velocity.x *= -1
		pass
	
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = false

	# We only update the y value of _velocity as we want to handle the horizontal movement ourselves.
	# i.e. we don't want velocity.x to become 0 when we hit a wall, we want it to flip with the code above
	_velocity.y = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false
	).y
	
	# We flip the Sprite depending on which way the enemy is moving.
	if _velocity.x > 0:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1

	_velocity.y += gravity * delta

func calculate_move_velocity(
		linear_velocity,
		direction,
		speed):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	return velocity


func _on_Hitbox_body_entered(body):
	if dead:
		return
	# print("BODY ENTERED!")
	if body.is_in_group("player"):
		# print("HIT!")
		body.emit_signal("hit")





func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()


func _on_Walker_stomp():
	# print("I got stomped!")
	if dead:
		return
	dead = true
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$AnimatedSprite.stop()
	self.set_collision_layer_bit(0, false)
	$AnimationPlayer.play("death")
	$HitSound.play()
