extends KinematicBody2D

signal stomp

export var speed = Vector2(120.0, 80.0)
export var initial_facing = -1
export var vertical = true
export var target_node_path:NodePath

var target_node
var _velocity = Vector2.ZERO
onready var gravity = 1000
const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0
onready var sprite = $AnimatedSprite
var dead = false
var initial_position = Vector2.ZERO
var vertical_dir = 0
var vert_targets = [0, 0, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	_velocity.x = speed.x * initial_facing
	initial_position = position
	if vertical:
		if target_node_path:
			target_node = get_node(target_node_path)
			vertical_dir = initial_position.y - target_node.position.y
			if vertical_dir > 0:
				vertical_dir = -1
				# the current target is always at index vd+1
				vert_targets[0] = target_node.position.y
				vert_targets[2] = initial_position.y
			else:
				vertical_dir = 1
				# the current target is always at index vd+1
				vert_targets[2] = target_node.position.y
				vert_targets[0] = initial_position.y
		else:
			# cant be vertical if no target
			vertical = false
	
func _physics_process(delta):

	if vertical:
		# check if we need to swap direction
		var ydelta = position.y - vert_targets[vertical_dir+1]
		if vertical_dir < 0 and ydelta < 0:
			vertical_dir = 1
		if vertical_dir > 0 and ydelta > 0:
			vertical_dir = -1
	
	var direction = Vector2(1, 0)
	if vertical:
		direction = Vector2(0, vertical_dir)
	else:
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

	# _velocity.y += gravity * delta

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
	print("BODY ENTERED!")
	if body.is_in_group("player"):
		print("HIT!")
		body.emit_signal("hit")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()


func _on_Flyer_stomp():
	print("I got stomped!")
	if dead:
		return
	dead = true
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$AnimatedSprite.stop()
	self.set_collision_layer_bit(0, false)
	$AnimationPlayer.play("death")
