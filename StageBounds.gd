extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_StageBounds_body_entered(body):
	print(body)
	if body.is_in_group("player"):
		var extents = $CollisionShape2D.shape.get_extents()
		var position = $CollisionShape2D.position
		print(extents, position)
		# -1 = NONE, 0 = LEFT, 1 = TOP, 2 = RIGHT, 3 = BOTTOM
		body.emit_signal("set_camera_limit", 0, (position.x - extents.x))
		body.emit_signal("set_camera_limit", 1, (position.y - extents.y))
		body.emit_signal("set_camera_limit", 2, (position.x + extents.x))
		body.emit_signal("set_camera_limit", 3, (position.y + extents.y))
