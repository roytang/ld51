extends Area2D

export var direction = Vector2(1, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DashArrow_body_entered(body):
	if body.is_in_group("player"):
		body.emit_signal("start_dash", direction)
		# queue_free()
